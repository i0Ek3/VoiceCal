import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/audio_service.dart';
import '../services/speech_service.dart';
import '../services/calculation_service.dart';
import '../services/tts_service.dart';
import '../models/calculation_result.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  
  bool _isRecording = false;
  bool _isProcessing = false;
  String _statusMessage = 'Tap and hold to record';
  CalculationResult? _result;
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Setup pulse animation for recording button
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }
  
  @override
  void dispose() {
    _pulseController.dispose();
    _textController.dispose();
    super.dispose();
  }
  
  // Start recording
  Future<void> _startRecording() async {
    final audioService = context.read<AudioService>();
    
    setState(() {
      _isRecording = true;
      _statusMessage = 'Recording... Speak your calculation';
      _result = null;
    });
    
    final success = await audioService.startRecording();
    
    if (!success) {
      setState(() {
        _isRecording = false;
        _statusMessage = 'Microphone permission denied';
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please grant microphone permission in Settings'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }
  
  // Stop recording and process
  Future<void> _stopRecording() async {
    final audioService = context.read<AudioService>();
    final speechService = context.read<SpeechService>();
    
    setState(() {
      _isRecording = false;
      _isProcessing = true;
      _statusMessage = 'Processing audio...';
    });
    
    try {
      // Stop recording
      final audioPath = await audioService.stopRecording();
      
      if (audioPath == null) {
        throw Exception('Failed to save recording');
      }
      
      // Transcribe audio
      setState(() {
        _statusMessage = 'Transcribing speech...';
      });
      
      final transcription = await speechService.transcribeAudio(audioPath);
      
      // Clean up audio file
      await audioService.deleteRecording(audioPath);
      
      // Validate transcription
      if (!speechService.isValidTranscription(transcription.text)) {
        throw Exception('Could not understand speech. Please try again.');
      }
      
      // Clean and set transcription
      final cleanedText = speechService.cleanTranscription(transcription.text);
      _textController.text = cleanedText;
      
      setState(() {
        _statusMessage = 'Transcription complete. Tap Calculate or edit text.';
      });
      
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: ${e.toString()}';
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }
  
  // Calculate result
  Future<void> _calculate() async {
    final text = _textController.text.trim();
    
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter or record a calculation')),
      );
      return;
    }
    
    final calculationService = context.read<CalculationService>();
    final ttsService = context.read<TtsService>();
    
    setState(() {
      _isProcessing = true;
      _statusMessage = 'Calculating...';
      _result = null;
    });
    
    try {
      final result = await calculationService.calculate(text);
      
      setState(() {
        _result = result;
        _statusMessage = result.success 
            ? 'Calculation complete!' 
            : 'Calculation error: ${result.error}';
      });
      
      // Speak result if enabled and successful
      if (result.success) {
        await ttsService.speakResult(result.result, result.explanation);
      }
      
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: ${e.toString()}';
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }
  
  // Clear all
  void _clear() {
    setState(() {
      _textController.clear();
      _result = null;
      _statusMessage = 'Tap and hold to record';
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('VoiceCal'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Status message
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      if (_isProcessing)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        Icon(
                          _result?.success == true 
                              ? Icons.check_circle 
                              : Icons.info_outline,
                          color: _result?.success == true 
                              ? Colors.green 
                              : theme.colorScheme.primary,
                        ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _statusMessage,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Recording button
              Center(
                child: GestureDetector(
                  onLongPressStart: (_) => _startRecording(),
                  onLongPressEnd: (_) => _stopRecording(),
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _isRecording ? _pulseAnimation.value : 1.0,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isRecording 
                                ? Colors.red 
                                : theme.colorScheme.primary,
                            boxShadow: [
                              BoxShadow(
                                color: (_isRecording ? Colors.red : theme.colorScheme.primary)
                                    .withOpacity(0.4),
                                blurRadius: 20,
                                spreadRadius: _isRecording ? 10 : 5,
                              ),
                            ],
                          ),
                          child: Icon(
                            _isRecording ? Icons.mic : Icons.mic_none,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              Text(
                _isRecording ? 'Release to stop' : 'Hold to record',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Text input
              TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  labelText: 'Calculation Text',
                  hintText: 'Edit transcription or type manually...',
                  prefixIcon: Icon(Icons.edit),
                ),
                maxLines: 3,
                enabled: !_isProcessing && !_isRecording,
              ),
              
              const SizedBox(height: 16),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isProcessing || _isRecording ? null : _calculate,
                      icon: const Icon(Icons.calculate),
                      label: const Text('Calculate'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isProcessing || _isRecording ? null : _clear,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      foregroundColor: theme.colorScheme.onSurface,
                    ),
                    child: const Icon(Icons.clear),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Result display
              if (_result != null) ...[
                Card(
                  color: _result!.success 
                      ? theme.colorScheme.primaryContainer 
                      : theme.colorScheme.errorContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _result!.success ? Icons.check_circle : Icons.error,
                              color: _result!.success 
                                  ? theme.colorScheme.onPrimaryContainer 
                                  : theme.colorScheme.onErrorContainer,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _result!.success ? 'Result' : 'Error',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: _result!.success 
                                    ? theme.colorScheme.onPrimaryContainer 
                                    : theme.colorScheme.onErrorContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        
                        if (_result!.success) ...[
                          const SizedBox(height: 16),
                          Text(
                            'Expression:',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _result!.expression,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontFamily: 'monospace',
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          Text(
                            'Answer:',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _result!.result,
                            style: theme.textTheme.displaySmall?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          Text(
                            'Explanation:',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _result!.explanation,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ] else ...[
                          const SizedBox(height: 8),
                          Text(
                            _result!.error ?? 'Unknown error',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onErrorContainer,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}