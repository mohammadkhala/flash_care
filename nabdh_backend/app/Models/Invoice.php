<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Invoice extends Model
{
    use SoftDeletes;

    protected $fillable = [
        'therapist_id', 'client_id', 'appointment_id', 'number',
        'issued_at', 'amount', 'discount', 'description', 'notes',
    ];

    protected function casts(): array
    {
        return [
            'issued_at' => 'date',
            'amount'    => 'decimal:2',
            'discount'  => 'decimal:2',
        ];
    }

    public function therapist() { return $this->belongsTo(Therapist::class); }
    public function client() { return $this->belongsTo(FinanceClient::class, 'client_id'); }
    public function appointment() { return $this->belongsTo(Appointment::class); }

    public function getTotalAttribute(): float
    {
        return max(0, round((float) $this->amount - (float) $this->discount, 2));
    }

    public function getNumberLabelAttribute(): string
    {
        return 'INV-' . str_pad((string) $this->number, 4, '0', STR_PAD_LEFT);
    }
}
