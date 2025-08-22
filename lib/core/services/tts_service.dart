import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  static final TTSService _instance = TTSService._internal();
  factory TTSService() => _instance;
  TTSService._internal();

  final FlutterTts _tts = FlutterTts();
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    
    await _tts.setLanguage('es-ES');
    await _tts.setPitch(1.0);
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    
    _isInitialized = true;
  }

  Future<void> speak(String text) async {
    await init();
    await _tts.stop(); // Detener cualquier texto anterior
    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _tts.stop();
  }
}
