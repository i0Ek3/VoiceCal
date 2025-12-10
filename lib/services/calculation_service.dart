import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/calculation_result.dart';
import '../utils/api_config.dart';

class CalculationService {
  static const String _claudeUrl = 'https://api.anthropic.com/v1/messages';
  static const String _claudeModel = 'claude-sonnet-4-20250514';
  
  // Calculate using Claude AI
  Future<CalculationResult> calculate(String text) async {
    try {
      final apiKey = ApiConfig.anthropicKey;
      
      // Prepare prompt
      final prompt = _buildCalculationPrompt(text);
      
      // Prepare request
      final response = await http.post(
        Uri.parse(_claudeUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': apiKey,
          'anthropic-version': '2023-06-01',
        },
        body: json.encode({
          'model': _claudeModel,
          'max_tokens': 1024,
          'messages': [
            {
              'role': 'user',
              'content': prompt,
            }
          ],
        }),
      );
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final content = jsonData['content'][0]['text'];
        
        // Parse the response
        return _parseCalculationResponse(text, content);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          'Claude API error: ${errorData['error']['message'] ?? 'Unknown error'}'
        );
      }
    } catch (e) {
      print('Error calculating: $e');
      return CalculationResult.error(
        'Failed to calculate: $e',
        originalText: text,
      );
    }
  }
  
  // Build calculation prompt
  String _buildCalculationPrompt(String text) {
    return '''You are a mathematical calculator assistant. Parse the following natural language text and perform the calculation.

User input: "$text"

Instructions:
1. Understand the mathematical expression from the natural language
2. Handle Chinese numbers (个十百千万亿) and English numbers (dozen, hundred, thousand, million, billion)
3. Support operations: +, -, *, /, ^, sqrt, sin, cos, tan, log, etc.
4. If asking for percentage, provide the result as a percentage
5. Be precise with decimal calculations

Respond ONLY in this JSON format (no markdown, no extra text):
{
  "expression": "the mathematical expression extracted",
  "result": "the calculated result",
  "explanation": "brief explanation of what was calculated"
}

Example inputs and outputs:
- "Calculate 30 times 10000 divided by 20000 as percentage" → {"expression": "30 * 10000 / 20000 * 100", "result": "15%", "explanation": "30 times 10000 equals 300000, divided by 20000 equals 15, as a percentage: 15%"}
- "请帮我计算三十乘以一万除以两万给出百分比" → {"expression": "30 * 10000 / 20000 * 100", "result": "15%", "explanation": "三十乘以一万等于三十万，除以两万等于十五，百分比为15%"}
- "square root of 16" → {"expression": "sqrt(16)", "result": "4", "explanation": "The square root of 16 is 4"}
- "sine of 30 degrees" → {"expression": "sin(30°)", "result": "0.5", "explanation": "The sine of 30 degrees is 0.5"}

Now calculate for the user input above.''';
  }
  
  // Parse calculation response
  CalculationResult _parseCalculationResponse(String originalText, String response) {
    try {
      // Try to extract JSON from response
      String jsonStr = response.trim();
      
      // Remove markdown code blocks if present
      if (jsonStr.startsWith('```')) {
        jsonStr = jsonStr.replaceAll(RegExp(r'```json\s*'), '');
        jsonStr = jsonStr.replaceAll(RegExp(r'```\s*'), '');
        jsonStr = jsonStr.trim();
      }
      
      // Parse JSON
      final jsonData = json.decode(jsonStr);
      
      return CalculationResult(
        originalText: originalText,
        expression: jsonData['expression'] ?? '',
        result: jsonData['result']?.toString() ?? '',
        explanation: jsonData['explanation'] ?? '',
        success: true,
      );
    } catch (e) {
      print('Error parsing calculation response: $e');
      print('Response was: $response');
      
      // Fallback: try to extract result from text
      return CalculationResult(
        originalText: originalText,
        expression: originalText,
        result: _extractResultFromText(response),
        explanation: response,
        success: false,
        error: 'Could not parse response properly',
      );
    }
  }
  
  // Extract result from plain text response (fallback)
  String _extractResultFromText(String text) {
    // Look for numbers in the response
    final numberPattern = RegExp(r'-?\d+\.?\d*%?');
    final matches = numberPattern.allMatches(text);
    
    if (matches.isNotEmpty) {
      return matches.first.group(0) ?? 'Error';
    }
    
    return 'Unable to calculate';
  }
  
  // Validate if text contains mathematical intent
  bool hasCalculationIntent(String text) {
    final keywords = [
      // English
      'calculate', 'compute', 'solve', 'what is', "what's",
      'plus', 'minus', 'times', 'divided', 'multiply', 'add', 'subtract',
      'square', 'root', 'power', 'percent', 'percentage',
      'sine', 'cosine', 'tangent', 'sin', 'cos', 'tan',
      // Chinese
      '计算', '算', '求', '多少', '等于',
      '加', '减', '乘', '除', '乘以', '除以',
      '平方', '开方', '根号', '次方', '百分比', '百分之',
      '正弦', '余弦', '正切',
    ];
    
    final lowerText = text.toLowerCase();
    return keywords.any((keyword) => lowerText.contains(keyword.toLowerCase()));
  }
}