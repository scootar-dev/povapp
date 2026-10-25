<?php

$uri = urldecode(parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH));

// Handle the request body for JSON
if ($_SERVER['REQUEST_METHOD'] === 'POST' && str_contains($_SERVER['CONTENT_TYPE'] ?? '', 'application/json')) {
    $rawInput = file_get_contents('php://input');
    if ($rawInput) {
        $_REQUEST = array_merge($_REQUEST ?? [], json_decode($rawInput, true) ?? []);
    }
}

if ($uri !== '/' && file_exists(__DIR__ . '/public' . $uri)) {
    return false;
}

require_once __DIR__ . '/public/index.php';
