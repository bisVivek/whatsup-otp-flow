<?php

namespace App\Models;

use Database\Factories\LoginCodeFactory;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Attributes\Hidden;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\MassPrunable;
use Illuminate\Database\Eloquent\Model;

#[Fillable(['phone', 'code_hash', 'expires_at', 'ip_address'])]
#[Hidden(['code_hash'])]
class LoginCode extends Model
{
    /** @use HasFactory<LoginCodeFactory> */
    use HasFactory, MassPrunable;

    protected function casts(): array
    {
        return [
            'attempts' => 'integer',
            'expires_at' => 'datetime',
            'consumed_at' => 'datetime',
        ];
    }

    /** Codes that can still be tried. */
    public function scopeUsable(Builder $query): void
    {
        $query->whereNull('consumed_at')->where('expires_at', '>', now());
    }

    public function isExpired(): bool
    {
        return $this->expires_at->isPast();
    }

    /** Old codes are useless after a day; `model:prune` clears them. */
    public function prunable(): Builder
    {
        return static::where('expires_at', '<', now()->subDay());
    }
}
