<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Third Party Services
    |--------------------------------------------------------------------------
    |
    | This file is for storing the credentials for third party services such
    | as Resend, Postmark, AWS, and more. This file provides the de facto
    | location for this type of information, allowing packages to have
    | a conventional file to locate the various service credentials.
    |
    */

    'postmark' => [
        'key' => env('POSTMARK_API_KEY'),
    ],

    'resend' => [
        'key' => env('RESEND_API_KEY'),
    ],

    'ses' => [
        'key' => env('AWS_ACCESS_KEY_ID'),
        'secret' => env('AWS_SECRET_ACCESS_KEY'),
        'region' => env('AWS_DEFAULT_REGION', 'us-east-1'),
    ],

    /*
    | WhatsApp sign in codes through the AMICA panel. The template must be
    | an approved WhatsApp "Authentication" template with a copy-code button.
    */
    'amica_whatsapp' => [
        'base_url' => env('AMICA_WHATSAPP_BASE_URL', 'https://chat.growwithamica.com'),
        'send_path' => env('AMICA_WHATSAPP_SEND_PATH'),
        'api_key' => env('AMICA_WHATSAPP_API_KEY'),
        'template' => env('AMICA_WHATSAPP_OTP_TEMPLATE', 'login_otp'),
        'language' => env('AMICA_WHATSAPP_TEMPLATE_LANGUAGE', 'en'),
        'timeout' => (int) env('AMICA_WHATSAPP_TIMEOUT', 10),
    ],

    'slack' => [
        'notifications' => [
            'bot_user_oauth_token' => env('SLACK_BOT_USER_OAUTH_TOKEN'),
            'channel' => env('SLACK_BOT_USER_DEFAULT_CHANNEL'),
        ],
    ],

];
