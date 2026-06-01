<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // Create admin user (also runs on shared DB with backend)
        User::updateOrCreate(
            ['phone' => '599000000', 'phone_country_code' => '+970'],
            [
                'type' => 'admin',
                'is_active' => true,
                'phone_verified_at' => now(),
                'password' => Hash::make('admin123'),
            ]
        );
    }
}
