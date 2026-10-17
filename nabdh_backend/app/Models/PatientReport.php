<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class PatientReport extends Model
{
    use SoftDeletes;

    protected $fillable = [
        'therapist_id', 'client_id', 'clinic_id', 'template_id', 'appointment_id',
        'title', 'assessed_at', 'data', 'notes', 'status',
    ];

    protected function casts(): array
    {
        return [
            'assessed_at' => 'date',
            'data'        => 'array',
        ];
    }

    public function therapist() { return $this->belongsTo(Therapist::class); }
    public function client() { return $this->belongsTo(FinanceClient::class, 'client_id'); }
    public function clinic() { return $this->belongsTo(Clinic::class); }
    public function template() { return $this->belongsTo(AssessmentTemplate::class, 'template_id'); }
}
