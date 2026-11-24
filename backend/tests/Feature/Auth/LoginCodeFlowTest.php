<?php

namespace Tests\Feature\Auth;

use App\Exceptions\LoginCodeDeliveryException;
use App\Models\LoginCode;
use App\Models\User;
use App\Services\Auth\LoginCodeSender;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class LoginCodeFlowTest extends TestCase
{
    use RefreshDatabase;

    private const REQUEST = '/api/v1/auth/otp/request';

    private const VERIFY = '/api/v1/auth/otp/verify';

    /** @var list<array{phone: string, code: string}> */
    private array $sent = [];

    private bool $senderFails = false;

    protected function setUp(): void
    {
        parent::setUp();

        config([
            'otp.test_accounts' => [],
            'otp.max_attempts' => 5,
            'otp.resend_after' => 30,
            'otp.default_country_code' => '91',
        ]);

        $this->app->instance(LoginCodeSender::class, new class($this) implements LoginCodeSender
        {
            public function __construct(private LoginCodeFlowTest $test) {}

            public function send(string $phone, string $code, int $minutes): void
            {
                $this->test->recordSend($phone, $code);
            }
        });
    }

    /**
     * Called by the fake sender bound in setUp().
     */
    public function recordSend(string $phone, string $code): void
    {
        if ($this->senderFails) {
            throw new LoginCodeDeliveryException('AMICA WhatsApp refused the message');
        }

        $this->sent[] = ['phone' => $phone, 'code' => $code];
    }

    public function test_an_invited_user_gets_a_code_on_whatsapp(): void
    {
        User::factory()->create(['phone' => '919876543210']);

        $this->postJson(self::REQUEST, ['phone' => '+91 98765 43210'])
            ->assertOk()
            ->assertJson(['expires_in' => 300, 'resend_in' => 30]);

        $this->assertCount(1, $this->sent);
        $this->assertSame('919876543210', $this->sent[0]['phone']);
        $this->assertMatchesRegularExpression('/^\d{6}$/', $this->sent[0]['code']);
        $this->assertDatabaseCount('login_codes', 1);
    }

    public function test_a_ten_digit_number_gets_the_default_country_code(): void
    {
        User::factory()->create(['phone' => '919876543210']);

        $this->postJson(self::REQUEST, ['phone' => '98765-43210'])->assertOk();

        $this->assertSame('919876543210', $this->sent[0]['phone']);
    }

    public function test_an_unknown_number_gets_the_same_answer_and_no_code(): void
    {
        $this->postJson(self::REQUEST, ['phone' => '919000000000'])
            ->assertOk()
            ->assertJson(['message' => 'If that number has an account, a code is on its way on WhatsApp']);

        $this->assertSame([], $this->sent);
        $this->assertDatabaseCount('login_codes', 0);
    }

    public function test_the_resend_cooldown_applies_to_known_and_unknown_numbers_alike(): void
    {
        User::factory()->create(['phone' => '919876543210']);

        foreach (['919876543210', '919000000000'] as $phone) {
            $this->postJson(self::REQUEST, ['phone' => $phone])->assertOk();
            $this->postJson(self::REQUEST, ['phone' => $phone])
                ->assertStatus(429)
                ->assertHeader('Retry-After')
                ->assertJsonStructure(['message', 'retry_after']);
        }
    }

    public function test_a_malformed_number_is_rejected(): void
    {
        foreach (['12345', 'not-a-number', '+0 123 456 7890'] as $phone) {
            $this->postJson(self::REQUEST, ['phone' => $phone])
                ->assertUnprocessable()
                ->assertJsonValidationErrors(['phone' => 'Enter a valid WhatsApp number']);
        }
    }

    public function test_a_whatsapp_failure_returns_503_and_lifts_the_cooldown(): void
    {
        User::factory()->create(['phone' => '919876543210']);
        $this->senderFails = true;

        $this->postJson(self::REQUEST, ['phone' => '919876543210'])
            ->assertStatus(503)
            ->assertJsonPath('message', "We couldn't send the code on WhatsApp. Try again in a moment");

        $this->senderFails = false;

        $this->postJson(self::REQUEST, ['phone' => '919876543210'])->assertOk();
        $this->assertCount(1, $this->sent);
    }

    public function test_the_right_code_returns_a_token_that_works(): void
    {
        $user = User::factory()->create(['phone' => '919876543210', 'email' => 'ana@example.com']);
        $this->postJson(self::REQUEST, ['phone' => '919876543210']);
        $code = $this->sent[0]['code'];

        $response = $this->postJson(self::VERIFY, [
            'phone' => '+91 98765 43210',
            'code' => $code,
            'device_name' => 'iPhone',
        ])->assertOk()
            ->assertJsonPath('token_type', 'Bearer')
            ->assertJsonPath('user.phone', '919876543210')
            ->assertJsonStructure(['token', 'expires_at', 'user' => ['id', 'name', 'email', 'phone']]);

        $this->withToken($response->json('token'))
            ->getJson('/api/v1/me')
            ->assertOk()
            ->assertJsonPath('data.phone', '919876543210');

        $this->assertNotNull(LoginCode::first()->consumed_at);
        $this->assertNotNull($user->fresh()->last_login_at);
        $this->assertNotNull($user->fresh()->phone_verified_at);
    }

    public function test_a_code_only_works_once(): void
    {
        $user = User::factory()->create();
        LoginCode::factory()->withCode('424242')->create(['phone' => $user->phone]);

        $this->postJson(self::VERIFY, ['phone' => $user->phone, 'code' => '424242'])->assertOk();
        $this->postJson(self::VERIFY, ['phone' => $user->phone, 'code' => '424242'])
            ->assertUnprocessable()
            ->assertJsonPath('message', 'That code has expired. Ask for a new one');
    }

    public function test_a_wrong_code_counts_down_and_then_burns_the_code(): void
    {
        $user = User::factory()->create();
        LoginCode::factory()->withCode('424242')->create(['phone' => $user->phone]);

        foreach ([4, 3, 2, 1] as $left) {
            $this->postJson(self::VERIFY, ['phone' => $user->phone, 'code' => '000000'])
                ->assertUnprocessable()
                ->assertJsonValidationErrors(['code' => "That code isn't right"])
                ->assertJsonPath('attempts_left', $left);
        }

        $this->postJson(self::VERIFY, ['phone' => $user->phone, 'code' => '000000'])
            ->assertJsonPath('message', 'Too many wrong tries. Ask for a new code');

        // Even the right code is refused now.
        $this->postJson(self::VERIFY, ['phone' => $user->phone, 'code' => '424242'])
            ->assertUnprocessable();
    }

    public function test_an_expired_code_is_refused(): void
    {
        $user = User::factory()->create();
        LoginCode::factory()->withCode('424242')->expired()->create(['phone' => $user->phone]);

        $this->postJson(self::VERIFY, ['phone' => $user->phone, 'code' => '424242'])
            ->assertUnprocessable()
            ->assertJsonPath('message', 'That code has expired. Ask for a new one');
    }

    public function test_asking_again_replaces_the_previous_code(): void
    {
        config(['otp.resend_after' => 0]);
        $user = User::factory()->create();
        LoginCode::factory()->withCode('424242')->create(['phone' => $user->phone]);

        $this->postJson(self::REQUEST, ['phone' => $user->phone])->assertOk();

        $this->postJson(self::VERIFY, ['phone' => $user->phone, 'code' => '424242'])
            ->assertUnprocessable();
    }

    public function test_a_test_account_signs_in_with_its_fixed_code_and_gets_no_message(): void
    {
        config(['otp.test_accounts' => ['919999999999' => '123456']]);
        $this->seed();

        $this->postJson(self::REQUEST, ['phone' => '9999999999'])->assertOk();
        $this->assertSame([], $this->sent);

        $this->postJson(self::VERIFY, ['phone' => '919999999999', 'code' => '123456'])
            ->assertOk()
            ->assertJsonPath('user.name', 'Deepak Kumar');
    }

    public function test_logout_revokes_only_the_current_token(): void
    {
        $user = User::factory()->create();
        $phone = $user->createToken('phone')->plainTextToken;
        $tablet = $user->createToken('tablet')->plainTextToken;

        $this->withToken($phone)->postJson('/api/v1/auth/logout')->assertOk();

        $this->assertDatabaseCount('personal_access_tokens', 1);
        $this->app['auth']->forgetGuards();
        $this->withToken($phone)->getJson('/api/v1/me')->assertUnauthorized();
        $this->app['auth']->forgetGuards();
        $this->withToken($tablet)->getJson('/api/v1/me')->assertOk();
    }
}
