import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  // Built-in demo keys (limited usage)
  static const String defaultOpenAIKey = 'sk-proj-demo-key-replace-with-real';
  static const String defaultAnthropicKey = 'sk-ant-demo-key-replace-with-real';
  
  // SharedPreferences keys
  static const String _openAIKeyPref = 'openai_api_key';
  static const String _anthropicKeyPref = 'anthropic_api_key';
  static const String _enableTtsPref = 'enable_tts';
  static const String _languagePref = 'language';
  
  static SharedPreferences? _prefs;
  
  // Initialize
  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  // OpenAI API Key
  static String get openAIKey {
    return _prefs?.getString(_openAIKeyPref) ?? defaultOpenAIKey;
  }
  
  static Future<void> setOpenAIKey(String key) async {
    await _prefs?.setString(_openAIKeyPref, key);
  }
  
  // Anthropic API Key
  static String get anthropicKey {
    return _prefs?.getString(_anthropicKeyPref) ?? defaultAnthropicKey;
  }
  
  static Future<void> setAnthropicKey(String key) async {
    await _prefs?.setString(_anthropicKeyPref, key);
  }
  
  // TTS Enable/Disable
  static bool get isTtsEnabled {
    return _prefs?.getBool(_enableTtsPref) ?? true;
  }
  
  static Future<void> setTtsEnabled(bool enabled) async {
    await _prefs?.setBool(_enableTtsPref, enabled);
  }
  
  // Language
  static String get language {
    return _prefs?.getString(_languagePref) ?? 'auto';
  }
  
  static Future<void> setLanguage(String lang) async {
    await _prefs?.setString(_languagePref, lang);
  }
  
  // Check if using default keys
  static bool get isUsingDefaultKeys {
    return openAIKey == defaultOpenAIKey || 
           anthropicKey == defaultAnthropicKey;
  }
  
  // Clear all settings
  static Future<void> clearAll() async {
    await _prefs?.clear();
  }
}