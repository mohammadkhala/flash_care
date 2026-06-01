<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;

class AdminSeeder extends Seeder
{
    public function run(): void
    {
        User::firstOrCreate(
            ['phone' => '599000000', 'phone_country_code' => '+970'],
            [
                'type' => 'admin',
                'is_active' => true,
                'phone_verified_at' => now(),
                'password' => bcrypt('123456'),
            ]
        );
    }
}
