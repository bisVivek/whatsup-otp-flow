<?php

namespace Tests\Feature\Auth;

use App\Exceptions\LoginCodeDeliveryException;
use App\Models\User;
use App\Services\Auth\AmicaWhatsAppSender;
use App\Services\Auth\LoginCodeSender;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\Client\Request;
use Illuminate\Support\Facades\Http;
use Tests\TestCase;

class AmicaWhatsAppSenderTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        Http::preventStrayRequests();
        config([
            'otp.sender' => 'amica',
            'otp.test_accounts' => [],
            'services.amica_whatsapp' => [
                'base_url' => 'https://chat.growwithamica.com',
                'send_path' => '/api/whatsapp/send-template',
                'api_key' => 'test-key',
                'template' => 'login_otp',
                'language' => 'en',
                'timeout' => 10,
            ],
        ]);
    }

    public function test_the_amica_sender_is_used_when_configured(): void
    {
        $this->assertInstanceOf(AmicaWhatsAppSender::class, app(LoginCodeSender::class));
    }

    public function test_a_code_request_sends_the_otp_template_to_amica(): void
    {
        Http::fake(['chat.growwithamica.com/*' => Http::response(['success' => true, 'message_id' => 'wamid.1'])]);
        User::factory()->create(['phone' => '919876543210']);

        $this->postJson('/api/v1/auth/otp/request', ['phone' => '9876543210'])->assertOk();

        Http::assertSent(function (Request $request): bool {
            $code = $request['template']['components'][0]['parameters'][0]['text'];

            return $request->url() === 'https://chat.growwithamica.com/api/whatsapp/send-template'
                && $request->hasHeader('Authorization', 'Bearer test-key')
                && $request['to'] === '919876543210'
                && $request['type'] === 'template'
                && $request['template']['name'] === 'login_otp'
                && $request['template']['language']['code'] === 'en'
                && preg_match('/^\d{6}$/', $code) === 1
                && $request['template']['components'][1]['parameters'][0]['text'] === $code;
        });
    }

    public function test_an_error_status_is_a_delivery_failure(): void
    {
        Http::fake(['chat.growwithamica.com/*' => Http::response(['error' => 'Invalid token'], 401)]);

        $this->expectException(LoginCodeDeliveryException::class);

        (new AmicaWhatsAppSender)->send('919876543210', '123456', 5);
    }

    public function test_a_200_with_success_false_is_a_delivery_failure(): void
    {
        Http::fake(['chat.growwithamica.com/*' => Http::response(['success' => false, 'message' => 'Template not approved'])]);

        $this->expectException(LoginCodeDeliveryException::class);

        (new AmicaWhatsAppSender)->send('919876543210', '123456', 5);
    }

    public function test_an_unreachable_panel_is_a_delivery_failure(): void
    {
        Http::fake(['chat.growwithamica.com/*' => Http::failedConnection()]);

        $this->expectException(LoginCodeDeliveryException::class);

        (new AmicaWhatsAppSender)->send('919876543210', '123456', 5);
    }

    public function test_missing_credentials_fail_without_calling_out(): void
    {
        config(['services.amica_whatsapp.api_key' => null]);

        $this->expectException(LoginCodeDeliveryException::class);

        (new AmicaWhatsAppSender)->send('919876543210', '123456', 5);
    }
}
