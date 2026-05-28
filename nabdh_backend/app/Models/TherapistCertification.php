<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class TherapistCertification extends Model
{
    protected $table = 'therapist_certifications';

    protected $fillable = [
        'therapist_id', 'name', 'issuing_organization', 'issue_date',
        'expiry_date', 'credential_id', 'file',
    ];

    protected $casts = [
        'issue_date'  => 'date',
        'expiry_date' => 'date',
    ];

    public function therapist(): BelongsTo
    {
        return $this->belongsTo(Therapist::class);
    }
}
