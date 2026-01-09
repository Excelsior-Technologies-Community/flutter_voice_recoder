import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_voice_recoder/voice_recorder_plus.dart';

void main() => runApp(
  const MaterialApp(home: RecorderDemo(), debugShowCheckedModeBanner: false),
);

class RecorderDemo extends StatefulWidget {
  const RecorderDemo({super.key});

  @override
  State<RecorderDemo> createState() => _RecorderDemoState();
}

class _RecorderDemoState extends State<RecorderDemo> {
  late final VoiceRecorder recorder;
  RecorderState state = RecorderState.initial();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    recorder = VoiceRecorder();

    await recorder.initialize();

    recorder.stateStream.listen((s) {
      if (mounted) {
        setState(() => state = s);
      }
    });

    setState(() => _isInitialized = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Recorder'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.blueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Timer box
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 32,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _formatDuration(state.durationMs),
                      style: const TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Buttons
                  if (state.isIdle)
                    _wideButton(
                      icon: Icons.mic,
                      label: 'START RECORDING',
                      color: Colors.redAccent,
                      onTap: _startRecording,
                    ),

                  if (state.isRecording) ...[
                    _wideButton(
                      icon: Icons.pause,
                      label: 'PAUSE',
                      color: Colors.orange,
                      onTap: _pauseRecording,
                    ),
                    const SizedBox(height: 12),
                    _wideButton(
                      icon: Icons.stop,
                      label: 'STOP',
                      color: Colors.red,
                      onTap: _stopRecording,
                    ),
                  ],

                  if (state.isPaused) ...[
                    _wideButton(
                      icon: Icons.play_arrow,
                      label: 'RESUME',
                      color: Colors.green,
                      onTap: _resumeRecording,
                    ),
                    const SizedBox(height: 12),
                    _wideButton(
                      icon: Icons.stop,
                      label: 'STOP',
                      color: Colors.red,
                      onTap: _stopRecording,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _wideButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 22),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 3,
        ),
      ),
    );
  }

  Future<void> _startRecording() async {
    final dir = Directory('/storage/emulated/0/Music/VoiceRecorder');

    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final path =
        '${dir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await recorder.start(filePath: path);
  }

  Future<void> _pauseRecording() async {
    await recorder.pause();
  }

  Future<void> _resumeRecording() async {
    await recorder.resume();
  }

  Future<void> _stopRecording() async {
    final result = await recorder.stop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recording Saved',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text('Duration: ${_formatDuration(result.durationMs)}'),
                  Text('Size: ${_formatFileSize(result.fileSizeBytes)}'),
                  Text(
                    result.filePath,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    debugPrint('Saved to: ${result.filePath}');
  }

  String _formatDuration(int ms) {
    final seconds = (ms ~/ 1000) % 60;
    final minutes = (ms ~/ 60000);
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  void dispose() {
    recorder.dispose();
    super.dispose();
  }
}
