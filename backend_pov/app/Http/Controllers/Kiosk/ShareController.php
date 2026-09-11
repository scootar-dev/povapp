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
        $this->ensureStudioScope($request, $session);

        $data = $request->validate([
            'channel' => 'required|in:whatsapp,email',
            'recipient' => 'required|string|max:255',
        ]);

        // Pastikan digital output sudah tersedia sebelum share
        $hasDigital = $session->outputs()->where('type', 'digital_image')->exists();
        if (! $hasDigital) {
            return response()->json(['message' => 'Output digital belum tersedia. Render terlebih dahulu.'], 422);
        }

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

    private function ensureStudioScope(Request $request, Session $session): void
    {
        $studioId = $request->attributes->get('studio_id');
        if ((int) $session->studio_id !== (int) $studioId) {
            abort(403, 'Sesi tidak termasuk studio ini.');
        }
    }
}
