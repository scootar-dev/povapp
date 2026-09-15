<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Http\Resources\SessionResource;
use App\Models\Session;
use Illuminate\Http\Request;

class SessionController extends Controller
{
    public function index(Request $request)
    {
        $query = Session::with(['studio', 'frame'])->latest();

        if ($request->filled('studio_id')) {
            $query->where('studio_id', $request->studio_id);
        }
        if ($request->filled('status')) {
            $query->where('status', $request->status);
        }
        if ($request->filled('date_from')) {
            $query->whereDate('created_at', '>=', $request->date_from);
        }
        if ($request->filled('date_to')) {
            $query->whereDate('created_at', '<=', $request->date_to);
        }

        return SessionResource::collection($query->paginate(25));
    }

    public function show(Session $session)
    {
        $session->load(['studio', 'frame', 'photos', 'outputs', 'printLogs', 'shareLogs']);

        return new SessionResource($session);
    }
}
