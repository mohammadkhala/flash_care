<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Patient extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id', 'full_name', 'avatar', 'date_of_birth', 'gender',
        'city', 'medical_history', 'allergies',
        'emergency_contact_name', 'emergency_contact_phone',
    ];

    protected function casts(): array
    {
        return ['date_of_birth' => 'date:Y-m-d'];
    }

    public function user() { return $this->belongsTo(User::class); }
    public function appointments() { return $this->hasMany(Appointment::class); }
    public function homePrograms() { return $this->hasMany(HomeProgram::class); }
    public function painDiary() { return $this->hasMany(PainDiary::class); }
    public function reviews() { return $this->hasMany(Review::class); }
    public function prescriptions() { return $this->hasMany(Prescription::class); }
    public function assessments() { return $this->hasMany(PatientAssessment::class); }
}
