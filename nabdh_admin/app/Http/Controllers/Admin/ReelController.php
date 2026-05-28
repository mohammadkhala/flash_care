<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Reel;
use Illuminate\Http\Request;

class ReelController extends Controller
{
    public function index(Request $request)
    {
        $query = Reel::with('therapist')->latest();

        if ($request->status) {
            $query->where('status', $request->status);
        }

        $reels = $query->paginate(16)->withQueryString();

        return view('admin.reels.index', compact('reels'));
    }

    public function approve(Reel $reel)
    {
        $reel->update(['status' => 'approved']);
        return back()->with('success', 'تم نشر الريل');
    }

    public function reject(Request $request, Reel $reel)
    {
        $request->validate(['reason' => 'required|string|max:300']);
        $reel->update(['status' => 'rejected', 'rejection_reason' => $request->reason]);
        return back()->with('success', 'تم رفض الريل');
    }

    public function destroy(Reel $reel)
    {
        $reel->delete();
        return back()->with('success', 'تم حذف الريل');
    }
}
