<?php
require "vendor/autoload.php";
$app = require_once "bootstrap/app.php";
$app->make("Illuminate\Contracts\Console\Kernel")->bootstrap();

$request = \Illuminate\Http\Request::create("/api/kiosk/sessions", "POST", [], [], [], [
    "CONTENT_TYPE" => "application/json",
], json_encode(["frame_id" => 2]));

$controller = new \App\Http\Controllers\Kiosk\SessionController();
$response = $controller->store($request);
echo $response->getContent();
