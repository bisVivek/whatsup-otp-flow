<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Date;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class DashboardTest extends TestCase
{
    use RefreshDatabase;

    public function test_guests_are_turned_away(): void
    {
        $this->getJson('/api/v1/dashboard')->assertUnauthorized();
    }

    public function test_the_dashboard_counts_the_days_progress_has_been_stuck(): void
    {
        Date::setTestNow('2026-11-24 10:00:00');
        Sanctum::actingAs(User::factory()->create());

        $this->getJson('/api/v1/dashboard')
            ->assertOk()
            ->assertJsonPath('data.title', 'Coming soon')
            ->assertJsonPath('data.progress.percent', 97)
            ->assertJsonPath('data.progress.stuck_since', '2026-03-14')
            ->assertJsonPath('data.progress.days_stuck', 255)
            ->assertJsonPath('data.stats.0.value', '0')
            ->assertJsonPath('data.notify_launch', false)
            ->assertJsonStructure(['data' => [
                'quip',
                'stats' => [['label', 'value', 'note']],
                'roadmap' => [['title', 'status', 'state']],
            ]]);
    }

    public function test_launch_notifications_can_be_turned_on_and_off(): void
    {
        $user = User::factory()->create();
        Sanctum::actingAs($user);

        $this->postJson('/api/v1/launch-notification')->assertOk()->assertJsonPath('notify_launch', true);
        $this->assertTrue($user->fresh()->notify_launch);

        $this->deleteJson('/api/v1/launch-notification')->assertOk()->assertJsonPath('notify_launch', false);
        $this->assertFalse($user->fresh()->notify_launch);
    }
}
