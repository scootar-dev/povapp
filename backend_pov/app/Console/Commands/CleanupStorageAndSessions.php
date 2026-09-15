<?php

namespace App\Console\Commands;

use App\Models\Photo;
use App\Models\Session;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Storage;

class CleanupStorageAndSessions extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'pov:cleanup {--days=30 : Number of days after which completed/abandoned session storage files are deleted}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Clean up abandoned sessions, unused retake photos, and old session storage files';

    /**
     * Execute the console command.
     */
    public function handle(): void
    {
        $this->info('Starting POV photobooth cleanup task...');

        // 1. Mark stale sessions (> 2 hours without completion) as abandoned
        $abandonedCount = Session::whereIn('status', ['started', 'shooting'])
            ->where('started_at', '<=', now()->subHours(2))
            ->update(['status' => 'abandoned']);

        $this->info("Marked {$abandonedCount} stale sessions as abandoned.");

        // 2. Delete unselected retake photos (is_selected = false) > 6 hours old
        $unselectedPhotos = Photo::where('is_selected', false)
            ->where('created_at', '<=', now()->subHours(6))
            ->get();

        $deletedRetakes = 0;
        foreach ($unselectedPhotos as $photo) {
            if ($photo->file_path && Storage::disk('public')->exists($photo->file_path)) {
                Storage::disk('public')->delete($photo->file_path);
            }
            $photo->delete();
            $deletedRetakes++;
        }

        $this->info("Deleted {$deletedRetakes} unselected retake photo files.");

        // 3. Cleanup storage files for old sessions (> $days days)
        $days = (int) $this->option('days');
        $oldSessions = Session::whereIn('status', ['completed', 'abandoned'])
            ->where('updated_at', '<=', now()->subDays($days))
            ->with(['photos', 'outputs'])
            ->get();

        $deletedFiles = 0;
        foreach ($oldSessions as $session) {
            // Delete raw photos
            foreach ($session->photos as $photo) {
                if ($photo->file_path && Storage::disk('public')->exists($photo->file_path)) {
                    Storage::disk('public')->delete($photo->file_path);
                    $deletedFiles++;
                }
            }
            // Delete rendered outputs
            foreach ($session->outputs as $output) {
                if ($output->file_path && Storage::disk('public')->exists($output->file_path)) {
                    Storage::disk('public')->delete($output->file_path);
                    $deletedFiles++;
                }
            }
            // Delete directory if empty
            $dir = "sessions/{$session->session_code}";
            if (Storage::disk('public')->exists($dir)) {
                Storage::disk('public')->deleteDirectory($dir);
            }
        }

        $this->info("Cleaned up {$deletedFiles} files from sessions older than {$days} days.");
        $this->info('Cleanup task finished successfully!');
    }
}
