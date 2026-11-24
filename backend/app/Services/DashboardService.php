<?php

namespace App\Services;

use App\Models\User;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Date;

/**
 * Content for the home screen while the real product is, as they say, soon.
 *
 * Figures grow with the days since progress stalled, so the joke keeps
 * itself up to date.
 */
class DashboardService
{
    /** @var list<string> */
    private const QUIPS = [
        'Nothing to see yet. We checked twice',
        "We're putting the final touches on the first touches",
        'Everything here is ready except everything here',
        'Good things take time. This is taking all of it',
        "We'd show you a chart, but it's a flat line",
        'This space is intentionally left almost blank',
        'Built with care, deadlines and very little else',
        "It works on our machine. We're shipping the machine",
    ];

    private const STUCK_SINCE = '2026-03-14';

    private const PERCENT = 97;

    /**
     * @return array{
     *     title: string,
     *     quip: string,
     *     progress: array{percent: int, status: string, caption: string, stuck_since: string, days_stuck: int},
     *     stats: list<array{label: string, value: string, note: string}>,
     *     roadmap: list<array{title: string, status: string, state: string}>,
     *     notify_launch: bool
     * }
     */
    public function for(User $user): array
    {
        $since = Carbon::parse(self::STUCK_SINCE)->startOfDay();
        $days = max(0, (int) $since->diffInDays(Date::now()->startOfDay()));
        $weeks = intdiv($days, 7);

        return [
            'title' => 'Coming soon',
            'quip' => self::QUIPS[array_rand(self::QUIPS)],
            'progress' => [
                'percent' => self::PERCENT,
                'status' => 'Building',
                'caption' => 'The last 3% is the hard part. It has been for a while',
                'stuck_since' => $since->toDateString(),
                'days_stuck' => $days,
            ],
            'stats' => [
                ['label' => 'Features shipped', 'value' => '0', 'note' => 'Same as last month'],
                ['label' => 'Meetings about it', 'value' => number_format($weeks * 3 + 2), 'note' => '+3 vs last week'],
                ['label' => 'Coffee', 'value' => number_format(intdiv($days * 2, 5)).' L', 'note' => 'Steady, like progress'],
            ],
            'roadmap' => [
                ['title' => 'Sign in', 'status' => 'Shipped. You used it', 'state' => 'shipped'],
                ['title' => 'Dark mode', 'status' => 'Shipped', 'state' => 'shipped'],
                ['title' => 'Home', 'status' => "You're looking at it", 'state' => 'building'],
                ['title' => 'Analytics', 'status' => 'When we find data', 'state' => 'planned'],
                ['title' => 'Notifications', 'status' => "We'll let you know", 'state' => 'planned'],
                ['title' => 'Settings', 'status' => 'Still picking defaults', 'state' => 'planned'],
            ],
            'notify_launch' => $user->notify_launch,
        ];
    }
}
