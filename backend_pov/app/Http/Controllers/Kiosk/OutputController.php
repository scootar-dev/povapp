<?php

namespace App\Http\Controllers\Kiosk;

use App\Http\Controllers\Controller;
use App\Jobs\RenderOutputJob;
use App\Models\Session;

class OutputController extends Controller
{
    /**
     * Trigger render gabungan foto+frame (300 DPI) secara async lewat queue.
     * Flutter polling GET /sessions/{id}/outputs sampai hasil muncul.
     */
    public function render(Session $session)
    {
        $session->update(['status' => 'rendering']);

        RenderOutputJob::dispatch($session);

        return response()->json(['message' => 'Render dimulai.'], 202);
    }

    public function index(Session $session)
    {
        return response()->json(['data' => $session->outputs]);
    }
}
