/// Validasi ringan sebelum kirim ke backend — pengiriman WA/Email sesungguhnya
/// (Fonnte/WABA, Mailgun) dikerjakan oleh queue job Laravel, bukan di client.
class ShareService {
  bool isValidWhatsAppNumber(String input) {
    final digits = input.replaceAll(RegExp(r'[^0-9]'), '');
    return digits.length >= 9 && digits.length <= 15;
  }

  bool isValidEmail(String input) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(input);
  }

  /// Menormalkan nomor lokal (mis. 08xxxx) ke format internasional 62xxxx
  /// yang umum dipakai provider WhatsApp API.
  String normalizeWhatsAppNumber(String input) {
    final digits = input.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.startsWith('0')) {
      return '62${digits.substring(1)}';
    }
    return digits;
  }
}
