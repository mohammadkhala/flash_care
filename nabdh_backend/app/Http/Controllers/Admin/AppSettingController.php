<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\AppSetting;
use App\Models\User;
use App\Services\FcmService;
use Illuminate\Http\Request;

class AppSettingController extends Controller
{
    public function index()
    {
        $settings = AppSetting::all()->groupBy('group');
        return view('admin.settings.index', compact('settings'));
    }

    public function update(Request $request)
    {
        $data = $request->except(['_token', '_method']);
        foreach ($data as $key => $value) {
            AppSetting::where('key', $key)->update(['value' => $value ?? '']);
        }
        // Handle unchecked booleans (checkboxes not sent when unchecked)
        AppSetting::where('type', 'boolean')->each(function ($s) use ($data) {
            if (!array_key_exists($s->key, $data)) {
                $s->update(['value' => '0']);
            }
        });
        return back()->with('success', 'تم حفظ الإعدادات بنجاح ✓');
    }

    /**
     * Send push notification to all users (or a specific role).
     */
    public function sendPush(Request $request)
    {
        $request->validate([
            'title' => 'required|string|max:100',
            'body'  => 'required|string|max:500',
            'role'  => 'nullable|in:all,patient,therapist',
        ]);

        $role = $request->role ?? 'all';
        $query = User::whereNotNull('fcm_token');
        if ($role !== 'all') {
            $query->where('role', $role);
        }

        $tokens = $query->pluck('fcm_token')->filter()->values()->toArray();

        if (empty($tokens)) {
            return back()->with('error', 'لا يوجد مستخدمون لديهم رمز إشعار.');
        }

        // Send in batches of 500 (FCM limit)
        $fcm = app(FcmService::class);
        $chunks = array_chunk($tokens, 500);
        foreach ($chunks as $chunk) {
            $fcm->sendToMultiple($chunk, $request->title, $request->body, [
                'type' => 'announcement',
            ]);
        }

        return back()->with('success', 'تم إرسال الإشعار إلى ' . count($tokens) . ' مستخدم ✓');
    }
}
