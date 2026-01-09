import 'dart:async';
import 'dart:io';

import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'recording_state.dart';
import 'recording_result.dart';

class VoiceRecorder {
  FlutterSoundRecorder? _recorder;

  RecorderState _currentState = RecorderState.initial();
  String? _currentPath;

  DateTime? _startTime;
  DateTime? _pauseStartTime;
  int _pausedDuration = 0;

  final _stateController = StreamController<RecorderState>.broadcast();
  Timer? _timer;

  RecorderState get state => _currentState;
  Stream<RecorderState> get stateStream => _stateController.stream;

  // ================= INIT =================

  Future<void> initialize() async {
    _recorder = FlutterSoundRecorder();
    await _recorder!.openRecorder();
  }

  // ================= PERMISSION =================

  Future<void> _checkPermission() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      throw Exception('Microphone permission denied');
    }
  }

  // ================= START =================

  /// If [filePath] is provided, recording will be saved there.
  /// Otherwise it will be saved in app documents directory.
  Future<void> start({String? filePath}) async {
    await _checkPermission();

    if (_currentState.isRecording) return;

    final path = filePath ?? await _defaultPath();
    _currentPath = path;

    await _recorder!.startRecorder(
      toFile: path,
      codec: Codec.aacMP4,
    );

    _startTime = DateTime.now();
    _pausedDuration = 0;

    _currentState = RecorderState(
      status: RecordingStatus.recording,
      filePath: path,
      durationMs: 0,
    );
    _emit();

    _startTimer();
  }

  // ================= PAUSE =================

  Future<void> pause() async {
    if (!_currentState.isRecording) return;

    await _recorder!.pauseRecorder();
    _pauseStartTime = DateTime.now();
    _stopTimer();

    _currentState = _currentState.copyWith(status: RecordingStatus.paused);
    _emit();
  }

  // ================= RESUME =================

  Future<void> resume() async {
    if (!_currentState.isPaused) return;

    await _recorder!.resumeRecorder();

    if (_pauseStartTime != null) {
      _pausedDuration +=
          DateTime.now().difference(_pauseStartTime!).inMilliseconds;
    }

    _currentState = _currentState.copyWith(status: RecordingStatus.recording);
    _emit();

    _startTimer();
  }

  // ================= STOP =================

  Future<RecordingResult> stop() async {
    if (_currentState.isIdle) {
      throw Exception('No recording running');
    }

    _stopTimer();
    await _recorder!.stopRecorder();

    final file = File(_currentPath!);
    final size = await file.length();
    final duration = _calculateDuration();

    final result = RecordingResult(
      filePath: _currentPath!,
      durationMs: duration,
      fileSizeBytes: size,
      mimeType: 'audio/mp4',
      format: 'm4a',
    );

    _reset();
    return result;
  }

  // ================= CANCEL =================

  Future<void> cancel() async {
    _stopTimer();
    await _recorder?.stopRecorder();

    if (_currentPath != null) {
      final file = File(_currentPath!);
      if (await file.exists()) {
        await file.delete();
      }
    }

    _reset();
  }

  // ================= DISPOSE =================

  void dispose() {
    _stopTimer();
    _stateController.close();
    _recorder?.closeRecorder();
  }

  // ================= PRIVATE =================

  void _emit() {
    _stateController.add(_currentState);
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (_currentState.isRecording) {
        _currentState =
            _currentState.copyWith(durationMs: _calculateDuration());
        _emit();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  int _calculateDuration() {
    if (_startTime == null) return 0;

    final end = _currentState.isPaused
        ? _pauseStartTime ?? DateTime.now()
        : DateTime.now();

    return end.difference(_startTime!).inMilliseconds - _pausedDuration;
  }

  Future<String> _defaultPath() async {
    final dir = await getApplicationDocumentsDirectory();
    final ts = DateTime.now().millisecondsSinceEpoch;
    return '${dir.path}/recording_$ts.m4a';
  }

  void _reset() {
    _currentState = RecorderState.initial();
    _emit();

    _startTime = null;
    _pauseStartTime = null;
    _pausedDuration = 0;
    _currentPath = null;
  }
}
