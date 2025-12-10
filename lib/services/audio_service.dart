import 'dart:io';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioService {
  final AudioRecorder _recorder = AudioRecorder();
  String? _currentRecordingPath;
  bool _isRecording = false;
  
  bool get isRecording => _isRecording;
  
  // Request microphone permission
  Future<bool> requestPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }
  
  // Check if permission is granted
  Future<bool> hasPermission() async {
    final status = await Permission.microphone.status;
    return status.isGranted;
  }
  
  // Start recording
  Future<bool> startRecording() async {
    try {
      // Check permission
      if (!await hasPermission()) {
        final granted = await requestPermission();
        if (!granted) {
          return false;
        }
      }
      
      // Get temporary directory
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _currentRecordingPath = '${directory.path}/recording_$timestamp.m4a';
      
      // Start recording
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          sampleRate: 16000,
          bitRate: 128000,
          numChannels: 1,
        ),
        path: _currentRecordingPath!,
      );
      
      _isRecording = true;
      return true;
    } catch (e) {
      print('Error starting recording: $e');
      _isRecording = false;
      return false;
    }
  }
  
  // Stop recording and return file path
  Future<String?> stopRecording() async {
    try {
      if (!_isRecording) {
        return null;
      }
      
      final path = await _recorder.stop();
      _isRecording = false;
      
      // Verify file exists
      if (path != null && await File(path).exists()) {
        return path;
      }
      
      return _currentRecordingPath;
    } catch (e) {
      print('Error stopping recording: $e');
      _isRecording = false;
      return null;
    }
  }
  
  // Cancel recording
  Future<void> cancelRecording() async {
    try {
      await _recorder.cancel();
      _isRecording = false;
      
      // Delete the file if it exists
      if (_currentRecordingPath != null) {
        final file = File(_currentRecordingPath!);
        if (await file.exists()) {
          await file.delete();
        }
      }
    } catch (e) {
      print('Error canceling recording: $e');
    }
  }
  
  // Get recording duration (in seconds)
  Future<Duration?> getRecordingDuration() async {
    if (_currentRecordingPath == null) return null;
    
    try {
      final file = File(_currentRecordingPath!);
      if (!await file.exists()) return null;
      
      // For now, we'll estimate based on file size
      // A more accurate method would require audio file parsing
      final bytes = await file.length();
      final estimatedSeconds = bytes / (16000 * 2); // 16kHz, 16-bit
      return Duration(seconds: estimatedSeconds.round());
    } catch (e) {
      print('Error getting duration: $e');
      return null;
    }
  }
  
  // Delete temporary recording file
  Future<void> deleteRecording(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Error deleting recording: $e');
    }
  }
  
  // Cleanup
  void dispose() {
    _recorder.dispose();
  }
}