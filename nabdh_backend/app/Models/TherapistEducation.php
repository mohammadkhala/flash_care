<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class TherapistEducation extends Model
{
    protected $table = 'therapist_educations';

    protected $fillable = [
        'therapist_id', 'degree', 'institution', 'field_of_study',
        'graduation_year', 'certificate_file',
    ];

    public function therapist(): BelongsTo
    {
        return $this->belongsTo(Therapist::class);
    }
}
