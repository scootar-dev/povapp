<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\PrintLog;
use App\Models\Session;
use App\Models\ShareLog;
use Illuminate\Http\Request;

class ReportController extends Controller
{
    public function summary(Request $request)
    {
        $from = $request->input('date_from', now()->subDays(30)->toDateString());
        $to = $request->input('date_to', now()->toDateString());

        $sessions = Session::whereBetween('created_at', ["$from 00:00:00", "$to 23:59:59"]);

        return response()->json([
            'data' => [
                'total_sessions' => (clone $sessions)->count(),
                'completed_sessions' => (clone $sessions)->where('status', 'completed')->count(),
                'abandoned_sessions' => (clone $sessions)->where('status', 'abandoned')->count(),
                'total_prints' => PrintLog::where('status', 'success')
                    ->whereBetween('created_at', ["$from 00:00:00", "$to 23:59:59"])->count(),
                'total_shares' => ShareLog::where('status', 'sent')
                    ->whereBetween('created_at', ["$from 00:00:00", "$to 23:59:59"])->count(),
                'shares_by_channel' => ShareLog::where('status', 'sent')
                    ->whereBetween('created_at', ["$from 00:00:00", "$to 23:59:59"])
                    ->selectRaw('channel, count(*) as total')
                    ->groupBy('channel')
                    ->pluck('total', 'channel'),
            ],
        ]);
    }
}
