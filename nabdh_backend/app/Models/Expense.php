<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Expense extends Model
{
    use SoftDeletes;

    public const CATEGORIES = ['rent', 'equipment', 'salaries', 'supplies', 'utilities', 'other'];

    protected $fillable = ['therapist_id', 'category', 'amount', 'spent_at', 'description', 'receipt_path'];

    protected function casts(): array
    {
        return [
            'spent_at' => 'date',
            'amount'   => 'decimal:2',
        ];
    }

    public function therapist() { return $this->belongsTo(Therapist::class); }
}
