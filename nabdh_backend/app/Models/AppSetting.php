<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class AppSetting extends Model
{
    protected $fillable = ['key', 'value', 'label', 'type', 'group'];

    /** Get a single setting value by key. */
    public static function get(string $key, mixed $default = null): mixed
    {
        $s = static::where('key', $key)->first();
        return $s ? $s->value : $default;
    }

    /** Set a single setting value. */
    public static function set(string $key, mixed $value): void
    {
        static::where('key', $key)->update(['value' => $value]);
    }

    /** Return all settings as key→value map. */
    public static function map(): array
    {
        return static::all()->pluck('value', 'key')->toArray();
    }
}
