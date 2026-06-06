<?php

use App\Http\Controllers\Admin\AdminController;
use App\Http\Controllers\Api\AgoraController;
use App\Http\Controllers\Api\PublicController;
use App\Http\Controllers\Auth\AuthController;
use App\Http\Controllers\Patient\TherapistSearchController;
use App\Http\Controllers\Shared\CallController;
use App\Http\Controllers\Shared\MessageController;
use App\Http\Controllers\Therapist\AppointmentController as TherapistAppointmentController;
use App\Http\Controllers\Therapist\HomeProgramController;
use App\Http\Controllers\Therapist\ProfileController;
use App\Http\Controllers\Therapist\ReelController;
use App\Http\Controllers\Therapist\DocumentController as TherapistDocumentController;
use App\Http\Controllers\Therapist\ScheduleController;
use App\Http\Controllers\Patient\AppointmentController as PatientAppointmentController;
use App\Http\Controllers\Patient\HomeProgramController as PatientHomeProgramController;
use App\Http\Controllers\Patient\DocumentController as PatientDocumentController;
use Illuminate\Support\Facades\Route;

// ─── Public (no auth) ─────────────────────────────────────────
Route::get('app-settings', [PublicController::class, 'settings']);
Route::get('pages/{slug}',  [PublicController::class, 'page']);

// ─── Auth (Public) ────────────────────────────────────────────
Route::prefix('auth')->group(function () {
    Route::post('send-otp',       [AuthController::class, 'sendOtp']);
    Route::post('verify-otp',     [AuthController::class, 'verifyOtp']);
    Route::post('login',          [AuthController::class, 'login']);
    Route::post('forgot-password',[AuthController::class, 'forgotPassword']);
});

// ─── Auth (Protected — after OTP) ────────────────────────────
Route::middleware('auth:sanctum')->prefix('auth')->group(function () {
    Route::post('set-password', [AuthController::class, 'setPassword']);
});

// ─── Agora RTC Token (requires auth) ─────────────────────────
Route::middleware('auth:sanctum')->post('agora/token', [AgoraController::class, 'token']);

// Public specializations list
Route::get('specializations', function () {
    return response()->json(\App\Models\Specialization::where('is_active', true)->orderBy('name_ar')->get());
});

// Public therapist listing
Route::get('therapists', [TherapistSearchController::class, 'index']);
Route::get('therapists/nearby', [TherapistSearchController::class, 'nearby']);
Route::get('therapists/{therapist}', [TherapistSearchController::class, 'show']);
Route::get('therapists/{therapist}/slots', [TherapistSearchController::class, 'availableSlots']);

// ─── Authenticated Routes ─────────────────────────────────────
Route::middleware('auth:sanctum')->group(function () {

    Route::get('me', [AuthController::class, 'me']);
    Route::post('logout', [AuthController::class, 'logout']);
    Route::post('auth/fcm-token', [AuthController::class, 'updateFcmToken']);
    Route::delete('account', [AuthController::class, 'deleteAccount']);

    // ── Therapist Routes ──────────────────────────────────────
    Route::middleware('role:therapist')->prefix('therapist')->group(function () {

        // Profile completion & setup
        Route::post('profile/complete', [AuthController::class, 'completeTherapistProfile']);
        Route::get('profile', [ProfileController::class, 'show']);
        Route::put('profile', [ProfileController::class, 'update']);
        Route::post('profile/avatar', [ProfileController::class, 'uploadAvatar']);
        Route::post('profile/education', [ProfileController::class, 'addEducation']);
        Route::post('profile/certification', [ProfileController::class, 'addCertification']);
        Route::post('profile/language', [ProfileController::class, 'addLanguage']);

        // Therapist documents (CV, license, certificates)
        Route::get('documents',             [TherapistDocumentController::class, 'index']);
        Route::post('documents',            [TherapistDocumentController::class, 'store']);
        Route::delete('documents/{document}', [TherapistDocumentController::class, 'destroy']);
        Route::get('statistics', [ProfileController::class, 'statistics']);

        // Schedules & Clinics
        Route::get('clinics', [ScheduleController::class, 'clinicsIndex']);
        Route::post('clinics', [ScheduleController::class, 'clinicsStore']);
        Route::put('clinics/{clinic}', [ScheduleController::class, 'clinicsUpdate']);
        Route::delete('clinics/{clinic}', [ScheduleController::class, 'clinicsDestroy']);
        Route::get('schedules', [ScheduleController::class, 'index']);
        Route::put('schedules', [ScheduleController::class, 'update']);
        Route::post('unavailability', [ScheduleController::class, 'addUnavailability']);
        Route::delete('unavailability/{id}', [ScheduleController::class, 'removeUnavailability']);

        // Appointments
        Route::get('appointments', [TherapistAppointmentController::class, 'index']);
        Route::get('appointments/{appointment}', [TherapistAppointmentController::class, 'show']);
        Route::put('appointments/{appointment}/confirm', [TherapistAppointmentController::class, 'confirm']);
        Route::put('appointments/{appointment}/cancel', [TherapistAppointmentController::class, 'cancel']);
        Route::put('appointments/{appointment}/complete', [TherapistAppointmentController::class, 'complete']);
        Route::get('appointments/{appointment}/agora-token', [TherapistAppointmentController::class, 'generateAgoraToken']);
        Route::get('appointments/{appointment}/notes', [TherapistAppointmentController::class, 'getNotes']);
        Route::post('appointments/{appointment}/notes', [TherapistAppointmentController::class, 'saveNotes']);

        // Articles
        Route::get('articles', [\App\Http\Controllers\Therapist\ArticleController::class, 'index']);
        Route::post('articles', [\App\Http\Controllers\Therapist\ArticleController::class, 'store']);
        Route::post('articles/cover', [\App\Http\Controllers\Therapist\ArticleController::class, 'uploadCover']);
        Route::put('articles/{article}', [\App\Http\Controllers\Therapist\ArticleController::class, 'update']);
        Route::delete('articles/{article}', [\App\Http\Controllers\Therapist\ArticleController::class, 'destroy']);

        // Assessments
        Route::get('assessments', [\App\Http\Controllers\Therapist\AssessmentController::class, 'index']);
        Route::post('assessments', [\App\Http\Controllers\Therapist\AssessmentController::class, 'store']);

        // Patient medical documents (therapist can view if they share an appointment)
        Route::get('patients/{patient}/documents', [TherapistDocumentController::class, 'patientDocuments']);

        // Patients list (for starting conversations)
        // Shows ALL registered patients so therapists can initiate contact
        Route::get('patients', function () {
            $patients = \App\Models\Patient::select(['id', 'user_id', 'full_name', 'avatar'])
                ->orderBy('full_name')
                ->get();
            return response()->json($patients);
        });

        // Home Programs
        Route::get('home-programs', [HomeProgramController::class, 'index']);
        Route::post('home-programs', [HomeProgramController::class, 'store']);
        Route::get('home-programs/patient/{patientId}', [HomeProgramController::class, 'patientPrograms']);
        Route::delete('home-programs/{program}', [HomeProgramController::class, 'destroy']);
        Route::post('exercises/upload', [HomeProgramController::class, 'uploadExerciseMedia']);

        // Reels
        Route::get('reels', [ReelController::class, 'myReels']);
        Route::post('reels', [ReelController::class, 'store']);
        Route::delete('reels/{reel}', [ReelController::class, 'destroy']);

        // Patient Goals (therapist manages)
        Route::get('goals', [\App\Http\Controllers\Therapist\GoalController::class, 'index']);
        Route::post('goals', [\App\Http\Controllers\Therapist\GoalController::class, 'store']);
        Route::get('goals/{goal}', [\App\Http\Controllers\Therapist\GoalController::class, 'show']);
        Route::put('goals/{goal}', [\App\Http\Controllers\Therapist\GoalController::class, 'update']);
        Route::post('goals/{goal}/progress', [\App\Http\Controllers\Therapist\GoalController::class, 'updateProgress']);
        Route::delete('goals/{goal}', [\App\Http\Controllers\Therapist\GoalController::class, 'destroy']);
    });

    // ── Patient Routes ────────────────────────────────────────
    Route::middleware('role:patient')->prefix('patient')->group(function () {

        // Profile
        Route::post('profile/complete', [AuthController::class, 'completePatientProfile']);

        // Therapists & Booking
        Route::post('therapists/{therapist}/book', [TherapistSearchController::class, 'book']);

        // Appointments
        Route::get('appointments', [PatientAppointmentController::class, 'index']);
        Route::get('appointments/{appointment}', [PatientAppointmentController::class, 'show']);
        Route::put('appointments/{appointment}/cancel', [PatientAppointmentController::class, 'cancel']);
        Route::post('appointments/{appointment}/review', [PatientAppointmentController::class, 'submitReview']);
        Route::get('appointments/{appointment}/agora-token', [PatientAppointmentController::class, 'generateAgoraToken']);

        // Home Programs
        Route::get('home-programs', [PatientHomeProgramController::class, 'index']);
        Route::get('home-programs/{program}', [PatientHomeProgramController::class, 'show']);
        Route::post('exercises/{exercise}/complete', [PatientHomeProgramController::class, 'markComplete']);

        // Pain Diary
        Route::get('pain-diary', [PatientHomeProgramController::class, 'painDiary']);
        Route::post('pain-diary', [PatientHomeProgramController::class, 'logPain']);

        // Goals (patient read-only)
        Route::get('goals', [\App\Http\Controllers\Patient\GoalController::class, 'index']);
        Route::get('goals/{goal}', [\App\Http\Controllers\Patient\GoalController::class, 'show']);

        // Medical Documents
        Route::get('documents',           [PatientDocumentController::class, 'index']);
        Route::post('documents',          [PatientDocumentController::class, 'store']);
        Route::delete('documents/{document}', [PatientDocumentController::class, 'destroy']);
    });

    // ── WebRTC Call Signaling ─────────────────────────────────
    Route::post('calls/initiate',          [CallController::class, 'initiate']);
    Route::get('calls/{channel}',          [CallController::class, 'show']);
    Route::post('calls/{channel}/answer',  [CallController::class, 'answer']);
    Route::post('calls/{channel}/ice',     [CallController::class, 'addIce']);
    Route::post('calls/{channel}/status',  [CallController::class, 'updateStatus']);

    // ── Shared Routes ─────────────────────────────────────────
    Route::prefix('messages')->group(function () {
        Route::get('conversations', [MessageController::class, 'conversations']);
        Route::get('conversations/{conversation}', [MessageController::class, 'messages']);
        Route::post('send/{partnerId}', [MessageController::class, 'send']);
        Route::post('conversations/{conversation}/call-token', [MessageController::class, 'callToken']);
    });

    // Reels (public feed + likes + comments)
    Route::get('reels', [ReelController::class, 'feed']);
    Route::post('reels/{reel}/like', [ReelController::class, 'toggleLike']);
    Route::get('reels/{reel}/comments', [ReelController::class, 'comments']);
    Route::post('reels/{reel}/comments', [ReelController::class, 'addComment']);
    Route::delete('reels/comments/{comment}', [ReelController::class, 'deleteComment']);

    // Notifications
    Route::get('notifications', function () {
        return response()->json(\App\Models\PushNotification::where('user_id', request()->user()->id)
            ->orderByDesc('created_at')->paginate(20));
    });
    Route::get('notifications/unread-count', function () {
        $count = \App\Models\PushNotification::where('user_id', request()->user()->id)
            ->whereNull('read_at')->count();
        return response()->json(['count' => $count]);
    });
    Route::post('notifications/{id}/read', function (string $id) {
        \App\Models\PushNotification::where('user_id', request()->user()->id)->where('id', $id)
            ->update(['read_at' => now()]);
        return response()->json(['ok' => true]);
    });
    Route::post('notifications/read-all', function () {
        \App\Models\PushNotification::where('user_id', request()->user()->id)->whereNull('read_at')
            ->update(['read_at' => now()]);
        return response()->json(['ok' => true]);
    });
});

// ─── Admin Routes ─────────────────────────────────────────────
Route::middleware(['auth:sanctum', 'role:admin'])->prefix('admin')->group(function () {
    Route::get('dashboard', [AdminController::class, 'dashboard']);
    Route::get('therapists/pending', [AdminController::class, 'pendingTherapists']);
    Route::put('therapists/{therapist}/approve', [AdminController::class, 'approveTherapist']);
    Route::put('therapists/{therapist}/reject', [AdminController::class, 'rejectTherapist']);
    Route::get('reels/pending', [AdminController::class, 'pendingReels']);
    Route::put('reels/{reel}/approve', [AdminController::class, 'approveReel']);
    Route::put('reels/{reel}/reject', [AdminController::class, 'rejectReel']);
    Route::get('users', [AdminController::class, 'users']);
    Route::put('users/{user}/toggle-status', [AdminController::class, 'toggleUserStatus']);
});
