<?php

use App\Http\Controllers\Admin\AppointmentController;
use App\Http\Controllers\Admin\AppSettingController;
use App\Http\Controllers\Admin\AuthController;
use App\Http\Controllers\Admin\DashboardController;
use App\Http\Controllers\Admin\PageController;
use App\Http\Controllers\Admin\PatientController;
use App\Http\Controllers\Admin\ReelController;
use App\Http\Controllers\Admin\SpecializationController;
use App\Http\Controllers\Admin\TherapistController;
use Illuminate\Support\Facades\Route;

// ─── Auth ────────────────────────────────────────────────────────────────────
Route::get('login',  [AuthController::class, 'showLogin'])->name('login');
Route::post('login', [AuthController::class, 'login']);
Route::post('logout',[AuthController::class, 'logout'])->name('logout');

// ─── Admin Panel (protected) ─────────────────────────────────────────────────
Route::middleware(['auth', 'admin'])->prefix('admin')->name('admin.')->group(function () {

    Route::get('/', [DashboardController::class, 'index'])->name('dashboard');

    // Therapists
    Route::get('therapists',                       [TherapistController::class, 'index'])->name('therapists.index');
    Route::get('therapists/{therapist}',            [TherapistController::class, 'show'])->name('therapists.show');
    Route::post('therapists/{therapist}/approve',   [TherapistController::class, 'approve'])->name('therapists.approve');
    Route::post('therapists/{therapist}/reject',    [TherapistController::class, 'reject'])->name('therapists.reject');
    Route::post('therapists/{therapist}/toggle-featured', [TherapistController::class, 'toggleFeatured'])->name('therapists.featured');
    Route::post('therapists/{therapist}/toggle-active',   [TherapistController::class, 'toggleActive'])->name('therapists.active');
    Route::delete('therapists/{therapist}',         [TherapistController::class, 'destroy'])->name('therapists.destroy');

    // Patients
    Route::get('patients',                  [PatientController::class, 'index'])->name('patients.index');
    Route::get('patients/{user}',           [PatientController::class, 'show'])->name('patients.show');
    Route::post('patients/{user}/toggle-active', [PatientController::class, 'toggleActive'])->name('patients.active');
    Route::delete('patients/{user}',        [PatientController::class, 'destroy'])->name('patients.destroy');

    // Appointments
    Route::get('appointments', [AppointmentController::class, 'index'])->name('appointments.index');

    // Reels
    Route::get('reels',                    [ReelController::class, 'index'])->name('reels.index');
    Route::post('reels/{reel}/approve',    [ReelController::class, 'approve'])->name('reels.approve');
    Route::post('reels/{reel}/reject',     [ReelController::class, 'reject'])->name('reels.reject');
    Route::delete('reels/{reel}',          [ReelController::class, 'destroy'])->name('reels.destroy');

    // Specializations
    Route::get('specializations',                          [SpecializationController::class, 'index'])->name('specializations.index');
    Route::post('specializations',                         [SpecializationController::class, 'store'])->name('specializations.store');
    Route::put('specializations/{specialization}',         [SpecializationController::class, 'update'])->name('specializations.update');
    Route::post('specializations/{specialization}/toggle', [SpecializationController::class, 'toggleActive'])->name('specializations.toggle');

    // App Settings
    Route::get('settings',         [AppSettingController::class, 'index'])->name('settings.index');
    Route::put('settings',         [AppSettingController::class, 'update'])->name('settings.update');
    Route::post('settings/push',   [AppSettingController::class, 'sendPush'])->name('settings.push');

    // Pages (Terms & Privacy)
    Route::get('pages',                   [PageController::class, 'index'])->name('pages.index');
    Route::get('pages/{slug}/edit',       [PageController::class, 'edit'])->name('pages.edit');
    Route::put('pages/{slug}',            [PageController::class, 'update'])->name('pages.update');
});

// Redirect root → admin panel
Route::redirect('/', '/admin');
