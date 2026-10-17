<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class PatientReport extends Model
{
    use SoftDeletes;

    public const TYPES = [
        'initial'      => 'Initial Assessment',
        'reassessment' => 'Re-assessment',
        'progress'     => 'Progress Report',
        'discharge'    => 'Discharge Summary',
    ];

    public const REFERRALS = [
        'self'      => 'Self-referral',
        'physician' => 'Physician',
        'other'     => 'Other',
    ];

    protected $fillable = [
        'therapist_id', 'number', 'client_id', 'clinic_id', 'template_id', 'appointment_id',
        'title', 'report_type', 'referral_source', 'referral_name', 'medical_diagnosis',
        'sessions_per_week', 'plan_weeks', 'assessed_at', 'data', 'notes', 'status', 'finalized_at',
    ];

    protected function casts(): array
    {
        return [
            'assessed_at'  => 'date',
            'finalized_at' => 'datetime',
            'data'         => 'array',
        ];
    }

    public function therapist() { return $this->belongsTo(Therapist::class); }
    public function client() { return $this->belongsTo(FinanceClient::class, 'client_id'); }
    public function clinic() { return $this->belongsTo(Clinic::class); }
    public function template() { return $this->belongsTo(AssessmentTemplate::class, 'template_id'); }

    public function getNumberLabelAttribute(): ?string
    {
        return $this->number ? 'RPT-' . str_pad((string) $this->number, 4, '0', STR_PAD_LEFT) : null;
    }

    public function getPlanOfCareAttribute(): ?string
    {
        if (!$this->sessions_per_week && !$this->plan_weeks) return null;
        $parts = [];
        if ($this->sessions_per_week) $parts[] = $this->sessions_per_week . ' session' . ($this->sessions_per_week > 1 ? 's' : '') . ' / week';
        if ($this->plan_weeks) $parts[] = 'for ' . $this->plan_weeks . ' week' . ($this->plan_weeks > 1 ? 's' : '');
        $total = $this->sessions_per_week && $this->plan_weeks ? ' (' . ($this->sessions_per_week * $this->plan_weeks) . ' sessions)' : '';
        return implode(' ', $parts) . $total;
    }
}
