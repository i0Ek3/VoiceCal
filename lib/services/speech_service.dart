import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/calculation_result.dart';
import '../utils/api_config.dart';

class SpeechService {
  static const String _whisperUrl = 'https://api.openai.com/v1/audio/transcriptions';
  
  // Transcribe audio file to text using OpenAI Whisper
  Future<TranscriptionResult> transcribeAudio(String audioPath) async {
    try {
      final apiKey = ApiConfig.openAIKey;
      
      // Read audio file
      final audioFile = File(audioPath);
      if (!await audioFile.exists()) {
        throw Exception('Audio file not found');
      }
      
      // Prepare multipart request
      final request = http.MultipartRequest('POST', Uri.parse(_whisperUrl));
      request.headers['Authorization'] = 'Bearer $apiKey';
      
      // Add audio file
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          audioPath,
          filename: 'audio.m4a',
        ),
      );
      
      // Add model and language parameters
      request.fields['model'] = 'whisper-1';
      request.fields['response_format'] = 'json';
      
      // Auto-detect language or use configured language
      final language = ApiConfig.language;
      if (language != 'auto') {
        request.fields['language'] = language;
      }
      
      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        return TranscriptionResult(
          text: jsonData['text'] ?? '',
          language: jsonData['language'] ?? 'unknown',
          duration: (jsonData['duration'] ?? 0.0).toDouble(),
        );
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          'Whisper API error: ${errorData['error']['message'] ?? 'Unknown error'}'
        );
      }
    } catch (e) {
      debugPrint('Error transcribing audio: $e');
      throw Exception('Failed to transcribe audio: $e');
    }
  }
  
  // Validate transcription quality
  bool isValidTranscription(String text) {
    if (text.trim().isEmpty) return false;
    if (text.length < 2) return false;
    
    // Check if text contains at least some alphanumeric characters
    final hasContent = RegExp(r'[a-zA-Z0-9\u4e00-\u9fa5]').hasMatch(text);
    return hasContent;
  }
  
  // Clean up transcription text
  String cleanTranscription(String text) {
    // Remove extra whitespace
    text = text.trim().replaceAll(RegExp(r'\s+'), ' ');
    
    // Remove common filler words at start/end
    final fillers = ['um', 'uh', 'er', 'ah', '呃', '嗯', '那个'];
    for (final filler in fillers) {
      text = text.replaceAll(RegExp('\\b$filler\\b', caseSensitive: false), '');
    }
    
    return text.trim();
  }
}