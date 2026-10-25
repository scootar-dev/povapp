<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class ParseJson
{
    public function handle(Request $request, Closure $next): Response
    {
        if ($request->isJson()) {
            // Try to get JSON from Laravel's built-in parser first
            $jsonData = $request->json()->all();
            
            // If that fails, try reading from php://input directly
            if (empty($jsonData)) {
                $rawInput = file_get_contents('php://input');
                \Log::info('Raw input from php://input: ' . $rawInput);
                
                if ($rawInput) {
                    $data = json_decode($rawInput, true);
                    if (is_array($data)) {
                        $request->merge($data);
                    }
                }
            } elseif (is_array($jsonData)) {
                $request->merge($jsonData);
            }
        }
        return $next($request);
    }
}