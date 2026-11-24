<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

/**
 * Sign in moves from email codes to WhatsApp codes, so users get a phone
 * number and codes are keyed by it. Outstanding email codes are dropped:
 * they live for minutes and can no longer be matched to a phone.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            // Digits only, country code first, no "+": 919876543210.
            $table->string('phone', 20)->nullable()->unique()->after('email');
            $table->timestamp('phone_verified_at')->nullable()->after('phone');
        });

        DB::table('login_codes')->delete();

        Schema::table('login_codes', function (Blueprint $table) {
            $table->dropIndex(['email']);
            $table->renameColumn('email', 'phone');
        });

        Schema::table('login_codes', function (Blueprint $table) {
            $table->index('phone');
        });
    }

    public function down(): void
    {
        DB::table('login_codes')->delete();

        Schema::table('login_codes', function (Blueprint $table) {
            $table->dropIndex(['phone']);
            $table->renameColumn('phone', 'email');
        });

        Schema::table('login_codes', function (Blueprint $table) {
            $table->index('email');
        });

        Schema::table('users', function (Blueprint $table) {
            $table->dropUnique(['phone']);
            $table->dropColumn(['phone', 'phone_verified_at']);
        });
    }
};
