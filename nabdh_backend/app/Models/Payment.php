<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Payment extends Model
{
    use SoftDeletes;

    public const METHODS = ['cash', 'card', 'bank_transfer', 'other'];

    protected $fillable = ['therapist_id', 'client_id', 'amount', 'method', 'paid_at', 'notes'];

    protected function casts(): array
    {
        return [
            'paid_at' => 'date',
            'amount'  => 'decimal:2',
        ];
    }

    public function therapist() { return $this->belongsTo(Therapist::class); }
    public function client() { return $this->belongsTo(FinanceClient::class, 'client_id'); }
}
