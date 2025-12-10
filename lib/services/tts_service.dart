import 'package:flutter_tts/flutter_tts.dart';
import '../utils/api_config.dart';

class TtsService {
  final FlutterTts _tts = FlutterTts();
  bool _isInitialized = false;
  
  // Initialize TTS
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Set language (will auto-detect or use configured)
      await _tts.setLanguage('en-US');
      
      // Set speech rate (0.0 to 1.0)
      await _tts.setSpeechRate(0.5);
      
      // Set volume (0.0 to 1.0)
      await _tts.setVolume(1.0);
      
      // Set pitch (0.5 to 2.0)
      await _tts.setPitch(1.0);
      
      _isInitialized = true;
    } catch (e) {
      print('Error initializing TTS: $e');
    }
  }
  
  // Speak text
  Future<void> speak(String text, {String? language}) async {
    if (!ApiConfig.isTtsEnabled) return;
    
    try {
      await initialize();
      
      // Set language if provided
      if (language != null) {
        await _setLanguage(language);
      }
      
      // Speak
      await _tts.speak(text);
    } catch (e) {
      print('Error speaking: $e');
    }
  }
  
  // Stop speaking
  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (e) {
      print('Error stopping TTS: $e');
    }
  }
  
  // Set language based on detected language code
  Future<void> _setLanguage(String languageCode) async {
    try {
      // Map common language codes
      final languageMap = {
        'en': 'en-US',
        'zh': 'zh-CN',
        'zh-CN': 'zh-CN',
        'zh-TW': 'zh-TW',
        'ja': 'ja-JP',
        'ko': 'ko-KR',
        'es': 'es-ES',
        'fr': 'fr-FR',
        'de': 'de-DE',
        'it': 'it-IT',
        'pt': 'pt-PT',
        'ru': 'ru-RU',
      };
      
      final ttsLanguage = languageMap[languageCode] ?? 'en-US';
      await _tts.setLanguage(ttsLanguage);
    } catch (e) {
      print('Error setting language: $e');
    }
  }
  
  // Get available languages
  Future<List<dynamic>> getLanguages() async {
    try {
      await initialize();
      return await _tts.getLanguages();
    } catch (e) {
      print('Error getting languages: $e');
      return [];
    }
  }
  
  // Check if TTS is available
  Future<bool> isAvailable() async {
    try {
      await initialize();
      final languages = await _tts.getLanguages();
      return languages.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
  
  // Speak calculation result with context
  Future<void> speakResult(String result, String explanation) async {
    if (!ApiConfig.isTtsEnabled) return;
    
    try {
      // Create a natural sentence
      final sentence = 'The result is $result. $explanation';
      await speak(sentence);
    } catch (e) {
      print('Error speaking result: $e');
    }
  }
  
  // Dispose
  void dispose() {
    _tts.stop();
  }
}