<?php
require "vendor/autoload.php";
$app = require_once "bootstrap/app.php";
$app->make("Illuminate\Contracts\Console\Kernel")->bootstrap();

$request = \Illuminate\Http\Request::create("/api/test-request", "POST", [], [], [], [
    "CONTENT_TYPE" => "application/json",
], json_encode(["frame_id" => 2]));

$response = $app->handle($request);
echo $response->getContent();
