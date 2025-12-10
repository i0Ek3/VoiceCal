class CalculationResult {
  final String originalText;
  final String expression;
  final String result;
  final String explanation;
  final bool success;
  final String? error;
  
  CalculationResult({
    required this.originalText,
    required this.expression,
    required this.result,
    required this.explanation,
    required this.success,
    this.error,
  });
  
  factory CalculationResult.fromJson(Map<String, dynamic> json) {
    return CalculationResult(
      originalText: json['originalText'] ?? '',
      expression: json['expression'] ?? '',
      result: json['result'] ?? '',
      explanation: json['explanation'] ?? '',
      success: json['success'] ?? false,
      error: json['error'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'originalText': originalText,
      'expression': expression,
      'result': result,
      'explanation': explanation,
      'success': success,
      'error': error,
    };
  }
  
  factory CalculationResult.error(String message, {String originalText = ''}) {
    return CalculationResult(
      originalText: originalText,
      expression: '',
      result: '',
      explanation: '',
      success: false,
      error: message,
    );
  }
}

class TranscriptionResult {
  final String text;
  final String language;
  final double duration;
  
  TranscriptionResult({
    required this.text,
    required this.language,
    required this.duration,
  });
  
  factory TranscriptionResult.fromJson(Map<String, dynamic> json) {
    return TranscriptionResult(
      text: json['text'] ?? '',
      language: json['language'] ?? 'unknown',
      duration: (json['duration'] ?? 0.0).toDouble(),
    );
  }
}