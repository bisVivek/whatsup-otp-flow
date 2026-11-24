<?php

namespace App\Models;

use App\Services\Auth\PhoneNumber;
use Database\Factories\UserFactory;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Attributes\Hidden;
use Illuminate\Database\Eloquent\Casts\Attribute;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use InvalidArgumentException;
use Laravel\Sanctum\HasApiTokens;

#[Fillable(['name', 'email', 'phone', 'password', 'notify_launch'])]
#[Hidden(['password', 'remember_token'])]
class User extends Authenticatable
{
    /** @use HasFactory<UserFactory> */
    use HasApiTokens, HasFactory, Notifiable;

    /**
     * @var array<string, mixed>
     */
    protected $attributes = [
        'notify_launch' => false,
    ];

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'phone_verified_at' => 'datetime',
            'last_login_at' => 'datetime',
            'notify_launch' => 'boolean',
            'password' => 'hashed',
        ];
    }

    /**
     * Emails are stored lowercase so lookups never miss on case.
     *
     * @return Attribute<string, string>
     */
    protected function email(): Attribute
    {
        return Attribute::make(
            set: fn (string $value): string => strtolower(trim($value)),
        );
    }

    /**
     * WhatsApp numbers are stored normalized (919876543210) so a sign in
     * with "+91 98765 43210" finds the same user.
     *
     * @return Attribute<?string, ?string>
     */
    protected function phone(): Attribute
    {
        return Attribute::make(
            set: fn (?string $value): ?string => $value === null || trim($value) === ''
                ? null
                : (PhoneNumber::normalize($value) ?? throw new InvalidArgumentException("Not a valid phone number: {$value}")),
        );
    }
}
