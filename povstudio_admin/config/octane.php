<?php

return [

    'server' => env('OCTANE_SERVER', 'swoole'),

    'servers' => [

        'swoole' => [
            'host' => env('OCTANE_HOST', '127.0.0.1'),
            'port' => env('OCTANE_PORT', 8000),
            'workers' => (int) env('OCTANE_WORKERS', 4),
            'task_workers' => (int) env('OCTANE_TASK_WORKERS', 2),
            'max_requests' => (int) env('OCTANE_MAX_REQUESTS', 500),
            'reload' => filter_var(env('OCTANE_RELOAD', true), FILTER_VALIDATE_BOOLEAN),
            'ssl' => [
                'cert' => env('OCTANE_SSL_CERT'),
                'key' => env('OCTANE_SSL_KEY'),
            ],
        ],

        'roadrunner' => [
            'host' => env('OCTANE_HOST', '127.0.0.1'),
            'port' => env('OCTANE_PORT', 8000),
            'workers' => (int) env('OCTANE_WORKERS', 4),
            'max_requests' => (int) env('OCTANE_MAX_REQUESTS', 500),
        ],

    ],

    'watch' => [
        'paths' => [
            base_path('app'),
            base_path('config'),
            base_path('database/migrations'),
            base_path('database/seeders'),
            base_path('lang'),
            base_path('routes'),
        ],
        'ignored' => [
            base_path('storage'),
            base_path('bootstrap/cache'),
            base_path('public'),
            base_path('node_modules'),
            base_path('vendor'),
        ],
        'interval' => 1000,
    ],

    'flush' => [
        'psr6' => [
            'except' => [
                'config',
                'routes',
                'translations',
            ],
        ],
    ],

    'start' => [
        'actions' => [
            \Laravel\Octane\Commands\StartCommand::class,
        ],
        'commands' => [],
    ],

    'stop' => [
        'actions' => [
            \Laravel\Octane\Commands\StopCommand::class,
        ],
    ],

    'ssl' => [
        'cert' => env('OCTANE_SSL_CERT'),
        'key' => env('OCTANE_SSL_KEY'),
    ],

    'opcache' => [
        'enabled' => false,
        'scripts' => [],
    ],

];