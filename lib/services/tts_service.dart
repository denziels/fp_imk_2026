import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';

class TTSService extends GetxService {
  late FlutterTts _flutterTts;
  
  // Status global apakah suara sedang dimatikan
  final RxBool isMuted = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initTts();
  }

  void _initTts() async {
    _flutterTts = FlutterTts();
    
    // Konfigurasi dasar untuk Bahasa Indonesia
    await _flutterTts.setLanguage("id-ID");
    
    // Set speech properties
    await _flutterTts.setSpeechRate(1.0); // Normal rate
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setVolume(1.0);
  }

  /// Fungsi untuk membacakan teks
  Future<void> speak(String text) async {
    await _flutterTts.stop(); // Hentikan suara yang sedang berjalan sebelumnya
    
    // Di Web, suara terkadang butuh waktu untuk dimuat oleh browser.
    // Memanggil setLanguage tepat sebelum berbicara seringkali menyelesaikan masalah suara bahasa Inggris.
    await _flutterTts.setLanguage("id-ID");
    
    await _flutterTts.speak(text);
  }

  /// Fungsi untuk membacakan teks (hanya akan dipanggil otomatis jika tidak mute)
  Future<void> autoSpeak(String text) async {
    if (isMuted.value) return;
    await speak(text);
  }

  /// Fungsi untuk menyalakan/mematikan suara secara global
  void toggleMute() {
    isMuted.value = !isMuted.value;
    if (isMuted.value) {
      stop(); // Matikan suara yang sedang berjalan jika di-mute
    }
  }

  /// Fungsi untuk menghentikan pembacaan teks
  Future<void> stop() async {
    await _flutterTts.stop();
  }
}
