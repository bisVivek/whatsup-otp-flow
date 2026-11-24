<?php

use App\Models\User;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Schedule;

Artisan::command('user:invite {email} {name}', function (string $email, string $name): void {
    $user = User::updateOrCreate(['email' => $email], ['name' => $name]);

    $this->info("{$user->email} can now sign in with an emailed code");
})->purpose('Invite someone, since public sign up is off');

Schedule::command('model:prune')->daily();
Schedule::command('sanctum:prune-expired --hours=24')->daily();
