<?php

namespace App\Http\Controllers\Kiosk;

use App\Http\Controllers\Controller;
use App\Jobs\SendEmailShareJob;
use App\Jobs\SendWhatsAppShareJob;
use App\Models\Session;
use App\Models\ShareLog;
use Illuminate\Http\Request;

class ShareController extends Controller
{
    public function store(Request $request, Session $session)
    {
        $data = $request->validate([
            'channel' => 'required|in:whatsapp,email',
            'recipient' => 'required|string|max:255',
        ]);

        $shareLog = ShareLog::create([
            'session_id' => $session->id,
            'channel' => $data['channel'],
            'recipient' => $data['recipient'],
            'status' => 'queued',
            'provider' => $data['channel'] === 'whatsapp' ? 'fonnte' : 'mailgun',
        ]);

        if ($data['channel'] === 'whatsapp') {
            SendWhatsAppShareJob::dispatch($shareLog);
        } else {
            SendEmailShareJob::dispatch($shareLog);
        }

        return response()->json(['data' => $shareLog], 202);
    }
}
