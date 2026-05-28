<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class RoleMiddleware
{
    public function handle(Request $request, Closure $next, string $role): mixed
    {
        if (!$request->user()) {
            return response()->json(['message' => 'غير مصرح'], 401);
        }

        if ($request->user()->type !== $role) {
            return response()->json(['message' => 'غير مسموح لك بالوصول'], 403);
        }

        if ($request->user()->type === 'therapist') {
            // Allow profile setup routes regardless of approval status
            $setupRoutes = ['therapist/profile/complete', 'therapist/profile/avatar', 'therapist/profile/language'];
            $isSetupRoute = collect($setupRoutes)->contains(fn($r) => $request->is("api/$r"));

            if (!$isSetupRoute) {
                $therapist = $request->user()->therapist;
                if ($therapist && !$therapist->is_approved) {
                    return response()->json([
                        'message' => 'حسابك قيد المراجعة من قبل الإدارة',
                        'status' => 'pending_approval',
                    ], 403);
                }
            }
        }

        if (!$request->user()->is_active) {
            return response()->json(['message' => 'حسابك موقوف. تواصل مع الدعم.'], 403);
        }

        return $next($request);
    }
}
