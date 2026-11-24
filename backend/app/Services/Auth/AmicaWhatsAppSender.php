<?php

namespace App\Services\Auth;

use App\Exceptions\LoginCodeDeliveryException;
use Illuminate\Http\Client\ConnectionException;
use Illuminate\Http\Client\Response;
use Illuminate\Support\Facades\Http;

/**
 * Sends the code as an approved WhatsApp authentication template through
 * the AMICA panel (chat.growwithamica.com).
 *
 * Settings live in `services.amica_whatsapp`. The request body follows the
 * WhatsApp Cloud API template format, which WhatsApp BSP panels pass on to
 * Meta: the code fills the body's {{1}} and the "Copy code" button. If the
 * panel expects a different body, {@see payload()} is the only place to
 * change.
 *
 * Not retried: a resend would deliver a second message.
 */
class AmicaWhatsAppSender implements LoginCodeSender
{
    public function send(string $phone, string $code, int $minutes): void
    {
        $config = (array) config('services.amica_whatsapp');

        if (blank($config['api_key'] ?? null) || blank($config['send_path'] ?? null)) {
            throw new LoginCodeDeliveryException(
                'AMICA WhatsApp is not configured. Set AMICA_WHATSAPP_API_KEY and AMICA_WHATSAPP_SEND_PATH.',
            );
        }

        try {
            $response = Http::baseUrl((string) $config['base_url'])
                ->withToken((string) $config['api_key'])
                ->acceptJson()
                ->connectTimeout(5)
                ->timeout((int) ($config['timeout'] ?? 10))
                ->post((string) $config['send_path'], $this->payload($phone, $code, $config));
        } catch (ConnectionException $e) {
            throw new LoginCodeDeliveryException('Could not reach AMICA WhatsApp', ['phone' => $phone], $e);
        }

        if (! $this->accepted($response)) {
            throw new LoginCodeDeliveryException('AMICA WhatsApp refused the message', [
                'phone' => $phone,
                'status' => $response->status(),
                'body' => mb_substr($response->body(), 0, 1000),
            ]);
        }
    }

    /**
     * @param  array<string, mixed>  $config
     * @return array<string, mixed>
     */
    private function payload(string $phone, string $code, array $config): array
    {
        return [
            'messaging_product' => 'whatsapp',
            'recipient_type' => 'individual',
            'to' => $phone,
            'type' => 'template',
            'template' => [
                'name' => (string) $config['template'],
                'language' => ['code' => (string) $config['language']],
                'components' => [
                    [
                        'type' => 'body',
                        'parameters' => [['type' => 'text', 'text' => $code]],
                    ],
                    [
                        'type' => 'button',
                        'sub_type' => 'url',
                        'index' => '0',
                        'parameters' => [['type' => 'text', 'text' => $code]],
                    ],
                ],
            ],
        ];
    }

    /**
     * Some panels answer 200 with `"success": false` or `"status": "error"`.
     */
    private function accepted(Response $response): bool
    {
        if (! $response->successful()) {
            return false;
        }

        return $response->json('success') !== false
            && ! in_array($response->json('status'), ['error', 'failed'], true);
    }
}
