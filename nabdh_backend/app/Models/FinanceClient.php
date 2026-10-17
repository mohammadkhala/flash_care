<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class FinanceClient extends Model
{
    use SoftDeletes;

    protected $fillable = ['therapist_id', 'patient_id', 'code', 'name', 'phone', 'notes'];

    public function therapist() { return $this->belongsTo(Therapist::class); }
    public function patient() { return $this->belongsTo(Patient::class); }
    public function invoices() { return $this->hasMany(Invoice::class, 'client_id'); }
    public function payments() { return $this->hasMany(Payment::class, 'client_id'); }

    public function getCodeLabelAttribute(): string
    {
        return 'P-' . str_pad((string) $this->code, 3, '0', STR_PAD_LEFT);
    }
}
