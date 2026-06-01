<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\AppSetting;
use App\Models\Page;
use Illuminate\Http\JsonResponse;

class PublicController extends Controller
{
    /** GET /app-settings — public settings for the mobile apps */
    public function settings(): JsonResponse
    {
        $map = AppSetting::all()->pluck('value', 'key');
        return response()->json([
            'whatsapp_support'    => $map['whatsapp_support']    ?? '',
            'whatsapp_message'    => $map['whatsapp_message']    ?? 'مرحباً، أحتاج مساعدة',
            'maintenance_mode'    => (bool)($map['maintenance_mode'] ?? false),
            'maintenance_message' => $map['maintenance_message'] ?? '',
            'announcement_active' => (bool)($map['announcement_active'] ?? false),
            'announcement_text'   => $map['announcement_text']   ?? '',
            'min_app_version'     => $map['min_app_version']     ?? '1.0.0',
        ]);
    }

    /** GET /pages/{slug} — terms | privacy */
    public function page(string $slug): JsonResponse
    {
        $page = Page::where('slug', $slug)->where('is_active', true)->first();
        if (!$page) {
            return response()->json(['error' => 'not found'], 404);
        }
        return response()->json($page);
    }
}
