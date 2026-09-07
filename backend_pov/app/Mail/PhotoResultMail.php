<?php

namespace App\Mail;

use App\Models\Session;
use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Storage;

class PhotoResultMail extends Mailable
{
    use Queueable, SerializesModels;

    public function __construct(public Session $session)
    {
    }

    public function envelope(): Envelope
    {
        return new Envelope(subject: 'Hasil Foto Kamu di POV Studio 📸');
    }

    public function content(): Content
    {
        return new Content(
            markdown: 'emails.photo-result',
            with: [
                'digitalUrl' => optional($this->session->outputs->firstWhere('type', 'digital_image'))->file_path,
                'downloadPageUrl' => config('app.url') . '/download/' . $this->session->session_code,
            ],
        );
    }

    public function attachments(): array
    {
        $printOutput = $this->session->outputs->firstWhere('type', 'print_image');

        if (! $printOutput) {
            return [];
        }

        return [
            \Illuminate\Mail\Mailables\Attachment::fromStorageDisk('public', $printOutput->file_path),
        ];
    }
}
