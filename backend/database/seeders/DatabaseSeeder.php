<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * The invited demo account. With OTP_TEST_ACCOUNTS set in .env it signs
     * in with a fixed code; otherwise, with OTP_SENDER=log, its code lands in
     * the log. 919999999999 is a placeholder: put a real WhatsApp number here
     * to get real messages.
     */
    public function run(): void
    {
        User::updateOrCreate(
            ['email' => 'deepak.kumar@gmail.com'],
            ['name' => 'Deepak Kumar', 'phone' => '919999999999', 'password' => null],
        );
    }
}
