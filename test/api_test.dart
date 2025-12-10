// API Testing Tool for VoiceCal
// Run with: dart run test_api.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  print('');
  print('====================================');
  print('  VoiceCal API Testing Tool');
  print('====================================');
  print('');
  
  // Get API keys from user
  print('Enter your OpenAI API key (or press Enter to skip):');
  final openAIKey = stdin.readLineSync()?.trim() ?? '';
  
  print('Enter your Anthropic API key (or press Enter to skip):');
  final anthropicKey = stdin.readLineSync()?.trim() ?? '';
  
  print('');
  
  // Test OpenAI Whisper API (if key provided)
  if (openAIKey.isNotEmpty) {
    await testOpenAIAPI(openAIKey);
  } else {
    print('⊘ Skipping OpenAI API test (no key provided)');
  }
  
  print('');
  
  // Test Anthropic Claude API (if key provided)
  if (anthropicKey.isNotEmpty) {
    await testAnthropicAPI(anthropicKey);
  } else {
    print('⊘ Skipping Anthropic API test (no key provided)');
  }
  
  print('');
  print('====================================');
  print('  API Testing Complete');
  print('====================================');
  print('');
}

Future<void> testOpenAIAPI(String apiKey) async {
  print('Testing OpenAI API...');
  print('─────────────────────────────────');
  
  try {
    // Test with a simple text-to-speech request (cheaper than Whisper)
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/models'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('✓ OpenAI API key is valid');
      print('✓ Available models: ${data['data'].length}');
      
      // Check if whisper-1 is available
      final hasWhisper = data['data'].any((model) => 
        model['id'] == 'whisper-1'
      );
      
      if (hasWhisper) {
        print('✓ Whisper-1 model is available');
      } else {
        print('⚠ Whisper-1 model not found in available models');
      }
      
    } else if (response.statusCode == 401) {
      print('✗ OpenAI API key is invalid');
      print('  Status: ${response.statusCode}');
      print('  Error: Unauthorized');
    } else {
      print('⚠ OpenAI API returned status: ${response.statusCode}');
      final error = json.decode(response.body);
      print('  Error: ${error['error']['message']}');
    }
    
  } catch (e) {
    print('✗ Failed to test OpenAI API');
    print('  Error: $e');
  }
}

Future<void> testAnthropicAPI(String apiKey) async {
  print('Testing Anthropic API...');
  print('─────────────────────────────────');
  
  try {
    // Test with a simple calculation request
    final response = await http.post(
      Uri.parse('https://api.anthropic.com/v1/messages'),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01',
      },
      body: json.encode({
        'model': 'claude-sonnet-4-20250514',
        'max_tokens': 100,
        'messages': [
          {
            'role': 'user',
            'content': 'Calculate 2 + 2 and respond with just the number.',
          }
        ],
      }),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final result = data['content'][0]['text'];
      
      print('✓ Anthropic API key is valid');
      print('✓ Model: ${data['model']}');
      print('✓ Test calculation result: $result');
      
      // Verify result contains "4"
      if (result.contains('4')) {
        print('✓ Calculation engine working correctly');
      } else {
        print('⚠ Unexpected calculation result');
      }
      
    } else if (response.statusCode == 401) {
      print('✗ Anthropic API key is invalid');
      print('  Status: ${response.statusCode}');
      print('  Error: Unauthorized');
    } else if (response.statusCode == 403) {
      print('✗ Anthropic API key lacks permissions');
      print('  Status: ${response.statusCode}');
      print('  Error: Forbidden');
    } else {
      print('⚠ Anthropic API returned status: ${response.statusCode}');
      try {
        final error = json.decode(response.body);
        print('  Error: ${error['error']['message']}');
      } catch (e) {
        print('  Raw response: ${response.body}');
      }
    }
    
  } catch (e) {
    print('✗ Failed to test Anthropic API');
    print('  Error: $e');
  }
}

// Example usage instructions
/*
To run this test:

1. Ensure you have the http package:
   flutter pub add http

2. Run the test:
   dart run test_api.dart

3. Or create a Flutter app and run:
   flutter run test_api.dart

This will verify:
- API key validity
- Model availability
- Basic API functionality
- Calculation engine

If tests pass, your API keys are ready for VoiceCal!
*/