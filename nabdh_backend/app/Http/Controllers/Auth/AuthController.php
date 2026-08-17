<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\Patient;
use App\Models\Therapist;
use App\Models\User;
use App\Services\OtpService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public function __construct(private OtpService $otpService) {}

    // ── Registration: send OTP ────────────────────────────────────
    public function sendOtp(Request $request): JsonResponse
    {
        $request->validate([
            'phone'              => 'required|string|max:15',
            'phone_country_code' => ['required', 'string', 'regex:/^\+[1-9]\d{0,3}$/'],
            'type'               => 'required|in:therapist,patient',
        ]);

        // Block login-mode users from OTP (they should use login endpoint)
        $existing = User::where('phone', $request->phone)
            ->where('phone_country_code', $request->phone_country_code)
            ->first();

        if ($existing && $existing->phone_verified_at && $existing->password) {
            return response()->json([
                'message' => 'هذا الرقم مسجل مسبقاً. يرجى تسجيل الدخول بكلمة المرور.',
                'already_registered' => true,
            ], 422);
        }

        $user = User::firstOrCreate(
            ['phone' => $request->phone, 'phone_country_code' => $request->phone_country_code],
            ['type' => $request->type]
        );

        if ($user->type !== $request->type) {
            return response()->json(['message' => 'هذا الرقم مسجل بنوع حساب مختلف'], 422);
        }

        $sent = $this->otpService->generateAndSend($user);

        if (!$sent) {
            return response()->json(['message' => 'فشل إرسال رمز التحقق. حاول مجدداً.'], 500);
        }

        return response()->json([
            'message'      => 'تم إرسال رمز التحقق على واتساب',
            'is_new_user'  => !$user->phone_verified_at,
        ]);
    }

    // ── Registration: verify OTP ──────────────────────────────────
    public function verifyOtp(Request $request): JsonResponse
    {
        $request->validate([
            'phone'              => 'required|string',
            'phone_country_code' => ['required', 'string', 'regex:/^\+[1-9]\d{0,3}$/'],
            'otp'                => 'required|string|size:6',
            'fcm_token'          => 'nullable|string',
        ]);

        $user = User::where('phone', $request->phone)
            ->where('phone_country_code', $request->phone_country_code)
            ->first();

        if (!$user || !$user->isOtpValid($request->otp)) {
            throw ValidationException::withMessages(['otp' => 'رمز التحقق غير صحيح أو منتهي الصلاحية']);
        }

        $user->update([
            'phone_verified_at' => now(),
            'otp'               => null,
            'otp_expires_at'    => null,
            'fcm_token'         => $request->fcm_token ?? $user->fcm_token,
        ]);

        $isNewUser = $user->isTherapist()
            ? !$user->therapist()->exists()
            : !$user->patient()->exists();

        $needsPassword = !$user->password;

        $token = $user->createToken('nabdh-app')->plainTextToken;

        return response()->json([
            'token'          => $token,
            'user'           => $user->load($user->isTherapist() ? 'therapist' : 'patient'),
            'is_new_user'    => $isNewUser,
            'needs_password' => $needsPassword,
            'needs_profile'  => $isNewUser,
            'is_approved'    => $user->isTherapist() ? $user->therapist?->is_approved : true,
        ]);
    }

    // ── Registration: set password after OTP ─────────────────────
    public function setPassword(Request $request): JsonResponse
    {
        $request->validate([
            'password' => 'required|string|min:6|confirmed',
        ]);

        $request->user()->update([
            'password' => Hash::make($request->password),
        ]);

        return response()->json(['message' => 'تم تعيين كلمة المرور بنجاح']);
    }

    // ── Forgot password: send OTP to existing user ────────────────
    public function forgotPassword(Request $request): JsonResponse
    {
        $request->validate([
            'phone'              => 'required|string|max:15',
            'phone_country_code' => ['required', 'string', 'regex:/^\+[1-9]\d{0,3}$/'],
            'type'               => 'required|in:therapist,patient',
        ]);

        $user = User::where('phone', $request->phone)
            ->where('phone_country_code', $request->phone_country_code)
            ->where('type', $request->type)
            ->first();

        if (!$user) {
            return response()->json(['message' => 'لا يوجد حساب مرتبط بهذا الرقم'], 404);
        }

        $sent = $this->otpService->generateAndSend($user);

        if (!$sent) {
            return response()->json(['message' => 'فشل إرسال رمز التحقق. حاول مجدداً.'], 500);
        }

        return response()->json(['message' => 'تم إرسال رمز التحقق على واتساب']);
    }

    // ── Login: phone + password ───────────────────────────────────
    public function login(Request $request): JsonResponse
    {
        $request->validate([
            'phone'              => 'required|string',
            'phone_country_code' => ['required', 'string', 'regex:/^\+[1-9]\d{0,3}$/'],
            'password'           => 'required|string',
            'type'               => 'required|in:therapist,patient',
            'fcm_token'          => 'nullable|string',
        ]);

        $user = User::where('phone', $request->phone)
            ->where('phone_country_code', $request->phone_country_code)
            ->where('type', $request->type)
            ->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            throw ValidationException::withMessages([
                'phone' => 'رقم الهاتف أو كلمة المرور غير صحيحة',
            ]);
        }

        if (!$user->is_active) {
            return response()->json(['message' => 'حسابك موقوف. تواصل مع الدعم.'], 403);
        }

        if ($request->fcm_token) {
            $user->update(['fcm_token' => $request->fcm_token]);
        }

        $token = $user->createToken('nabdh-app')->plainTextToken;

        $isNewUser = $user->isTherapist()
            ? !$user->therapist()->exists()
            : !$user->patient()->exists();

        return response()->json([
            'token'         => $token,
            'user'          => $user->load($user->isTherapist() ? 'therapist' : 'patient'),
            'needs_profile' => $isNewUser,
            'is_approved'   => $user->isTherapist() ? $user->therapist?->is_approved : true,
        ]);
    }

    // ── Complete profiles ─────────────────────────────────────────
    public function completeTherapistProfile(Request $request): JsonResponse
    {
        $request->validate([
            'full_name'          => 'required|string|max:100',
            'title'              => 'nullable|string|max:100',
            'bio'                => 'nullable|string|max:1000',
            'gender'             => 'required|in:male,female',
            'years_experience'   => 'required|integer|min:0',
            'city'               => 'required|string',
            'degree'             => 'nullable|string|max:100',
            'avatar_path'        => 'nullable|string',
            'specialization_ids' => 'required|array|min:1',
            'specialization_ids.*' => 'exists:specializations,id',
        ]);

        $fields = $request->only(['full_name', 'title', 'bio', 'gender', 'years_experience', 'city', 'degree']);
        if ($request->filled('avatar_path')) {
            $fields['avatar'] = $request->avatar_path;
        }

        $therapist = Therapist::updateOrCreate(
            ['user_id' => $request->user()->id],
            $fields
        );

        $therapist->specializations()->sync($request->specialization_ids);

        return response()->json([
            'message'    => 'تم حفظ ملفك الشخصي. سيتم مراجعته من قِبل الإدارة.',
            'therapist'  => $therapist->load('specializations'),
        ]);
    }

    public function completePatientProfile(Request $request): JsonResponse
    {
        $request->validate([
            'full_name'     => 'required|string|max:100',
            'gender'        => 'required|in:male,female',
            'date_of_birth' => 'nullable|date',
            'city'          => 'nullable|string',
        ]);

        $patient = Patient::updateOrCreate(
            ['user_id' => $request->user()->id],
            $request->only(['full_name', 'gender', 'date_of_birth', 'city'])
        );

        return response()->json(['patient' => $patient]);
    }

    // ── Shared ────────────────────────────────────────────────────

    /** POST /auth/fcm-token — update FCM token after app launch */
    public function updateFcmToken(Request $request): JsonResponse
    {
        $request->validate(['fcm_token' => 'required|string|max:500']);
        $request->user()->update(['fcm_token' => $request->fcm_token]);
        return response()->json(['ok' => true]);
    }

    public function logout(Request $request): JsonResponse
    {
        // Clear FCM token on logout so no notifications sent to signed-out device
        $request->user()->update(['fcm_token' => null]);
        $request->user()->currentAccessToken()->delete();
        return response()->json(['message' => 'تم تسجيل الخروج']);
    }

    public function deleteAccount(Request $request): JsonResponse
    {
        $user = $request->user();

        // Require password confirmation before deletion
        $request->validate([
            'password' => 'required|string',
        ]);

        if (!\Hash::check($request->password, $user->password)) {
            return response()->json(['message' => 'كلمة المرور غير صحيحة'], 422);
        }

        // Delete profile & related data
        if ($user->isTherapist()) {
            $therapist = $user->therapist;
            if ($therapist) {
                $therapist->educations()->delete();
                $therapist->certifications()->delete();
                $therapist->languages()->delete();
                $therapist->documents()->delete();
                $therapist->schedules()->delete();
                $therapist->unavailabilities()->delete();
                $therapist->clinics()->delete();
                $therapist->reels()->delete();
                $therapist->delete();
            }
        } else {
            $user->patient?->delete();
        }

        $user->tokens()->delete();
        $user->delete();

        return response()->json(['message' => 'تم حذف الحساب نهائياً']);
    }

    public function me(Request $request): JsonResponse
    {
        $user = $request->user();
        $profile = $user->isTherapist()
            ? $user->load(['therapist.specializations', 'therapist.languages', 'therapist.clinics'])
            : $user->load('patient');

        return response()->json(['user' => $profile]);
    }
}
