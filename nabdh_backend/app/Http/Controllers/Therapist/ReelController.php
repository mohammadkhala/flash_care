<?php

namespace App\Http\Controllers\Therapist;

use App\Http\Controllers\Controller;
use App\Models\Reel;
use App\Models\ReelComment;
use App\Models\ReelLike;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class ReelController extends Controller
{
    // Therapist: list own reels
    public function myReels(Request $request): JsonResponse
    {
        $reels = Reel::where('therapist_id', $request->user()->therapist->id)
            ->latest()->get()
            ->map(fn($r) => $this->format($r, $request->user()));

        return response()->json($reels);
    }

    // Therapist: upload new reel
    public function store(Request $request): JsonResponse
    {
        $request->validate([
            'title'       => 'required|string|max:200',
            'description' => 'nullable|string|max:500',
            'video'       => 'required|file|mimetypes:video/mp4,video/quicktime,video/x-msvideo,video/mpeg|max:512000',
        ]);

        $videoPath = $request->file('video')->store('reels/videos', 'public');

        $reel = Reel::create([
            'therapist_id' => $request->user()->therapist->id,
            'title'        => $request->input('title'),
            'description'  => $request->input('description'),
            'video_url'    => $videoPath,
            'status'       => 'pending',
        ]);

        return response()->json(['reel' => $this->format($reel, $request->user())], 201);
    }

    // Therapist: delete own reel
    public function destroy(Reel $reel): JsonResponse
    {
        abort_if($reel->therapist_id !== request()->user()->therapist->id, 403);

        if ($reel->video_url && !str_starts_with($reel->video_url, 'http')) {
            Storage::disk('public')->delete($reel->video_url);
        }
        if ($reel->thumbnail_url && !str_starts_with($reel->thumbnail_url, 'http')) {
            Storage::disk('public')->delete($reel->thumbnail_url);
        }

        $reel->delete();
        return response()->json(['message' => 'تم حذف الريل']);
    }

    // Public feed (patients + therapists)
    public function feed(Request $request): JsonResponse
    {
        $reels = Reel::where('status', 'approved')
            ->where('is_active', true)
            ->with('therapist:id,full_name,avatar,title')
            ->latest()
            ->paginate(20);

        $user = $request->user();
        $reels->getCollection()->transform(fn($r) => $this->format($r, $user));

        return response()->json($reels);
    }

    // Toggle like
    public function toggleLike(Request $request, Reel $reel): JsonResponse
    {
        $userId   = $request->user()->id;
        $existing = ReelLike::where('reel_id', $reel->id)->where('user_id', $userId)->first();

        if ($existing) {
            $existing->delete();
            $reel->decrement('likes_count');
            return response()->json(['liked' => false, 'likes_count' => $reel->fresh()->likes_count]);
        }

        ReelLike::create(['reel_id' => $reel->id, 'user_id' => $userId]);
        $reel->increment('likes_count');
        return response()->json(['liked' => true, 'likes_count' => $reel->fresh()->likes_count]);
    }

    // Get comments
    public function comments(Reel $reel): JsonResponse
    {
        $comments = $reel->comments()
            ->with('user:id,phone')
            ->latest()
            ->paginate(30);

        // Attach display name from therapist/patient relation
        $comments->getCollection()->transform(function ($c) {
            $user = $c->user;
            $name = $user?->therapist?->full_name ?? $user?->patient?->full_name ?? 'مستخدم';
            $avatar = $user?->therapist?->avatar ?? $user?->patient?->avatar ?? null;
            return [
                'id'         => $c->id,
                'body'       => $c->body,
                'user_id'    => $c->user_id,
                'user_name'  => $name,
                'user_avatar'=> $avatar ? (rtrim(config('app.url'), '/') . '/storage/' . $avatar) : null,
                'created_at' => $c->created_at,
            ];
        });

        return response()->json($comments);
    }

    // Add comment
    public function addComment(Request $request, Reel $reel): JsonResponse
    {
        $request->validate(['body' => 'required|string|max:500']);

        $comment = $reel->comments()->create([
            'user_id' => $request->user()->id,
            'body'    => $request->body,
        ]);

        $reel->increment('comments_count');

        $user = $request->user();
        $name = $user->therapist?->full_name ?? $user->patient?->full_name ?? 'مستخدم';

        return response()->json([
            'id'         => $comment->id,
            'body'       => $comment->body,
            'user_id'    => $comment->user_id,
            'user_name'  => $name,
            'created_at' => $comment->created_at,
        ], 201);
    }

    // Delete comment
    public function deleteComment(Request $request, ReelComment $comment): JsonResponse
    {
        abort_if($comment->user_id !== $request->user()->id, 403);

        $comment->reel->decrement('comments_count');
        $comment->delete();

        return response()->json(['message' => 'تم حذف التعليق']);
    }

    private function format(Reel $reel, $user = null): array
    {
        $base     = rtrim(config('app.url'), '/');
        $videoUrl = $reel->video_url
            ? (str_starts_with($reel->video_url, 'http')
                ? $reel->video_url
                : "$base/storage/{$reel->video_url}")
            : null;

        $likedByMe = $user
            ? ReelLike::where('reel_id', $reel->id)->where('user_id', $user->id)->exists()
            : false;

        $therapist = $reel->therapist;
        $therapistAvatar = $therapist?->avatar
            ? (str_starts_with($therapist->avatar, 'http')
                ? $therapist->avatar
                : "$base/storage/{$therapist->avatar}")
            : null;

        return [
            'id'             => $reel->id,
            'title'          => $reel->title,
            'description'    => $reel->description,
            'video_url'      => $videoUrl,
            'likes_count'    => $reel->likes_count,
            'comments_count' => $reel->comments_count ?? 0,
            'views'          => $reel->views,
            'status'         => $reel->status,
            'is_approved'    => $reel->status === 'approved',
            'liked_by_me'    => $likedByMe,
            'therapist'      => $therapist ? [
                'id'     => $therapist->id,
                'name'   => $therapist->full_name,
                'title'  => $therapist->title,
                'avatar' => $therapistAvatar,
            ] : null,
            'created_at' => $reel->created_at,
        ];
    }
}
