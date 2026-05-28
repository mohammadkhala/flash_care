<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class PatientDocument extends Model
{
    protected $fillable = [
        'patient_id', 'title', 'type',
        'file_url', 'file_name', 'file_mime',
        'notes', 'doctor_name', 'document_date',
    ];

    protected $casts = [
        'document_date' => 'date',
    ];

    public function patient()
    {
        return $this->belongsTo(Patient::class);
    }

    /** Human-readable type label */
    public function getTypeLabelAttribute(): string
    {
        return match($this->type) {
            'diagnosis'    => 'تشخيص',
            'report'       => 'تقرير طبي',
            'prescription' => 'وصفة طبية',
            'scan'         => 'صورة أشعة',
            'lab'          => 'تحليل مختبري',
            default        => 'أخرى',
        };
    }
}
