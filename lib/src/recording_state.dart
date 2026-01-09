enum RecordingStatus {
  idle,
  recording,
  paused,
  stopping,
}

class RecorderState {
  final RecordingStatus status;
  final String? filePath;
  final int durationMs;
  final String? error;

  const RecorderState({
    required this.status,
    this.filePath,
    this.durationMs = 0,
    this.error,
  });

  factory RecorderState.initial() {
    return const RecorderState(status: RecordingStatus.idle);
  }

  bool get isIdle => status == RecordingStatus.idle;
  bool get isRecording => status == RecordingStatus.recording;
  bool get isPaused => status == RecordingStatus.paused;

  RecorderState copyWith({
    RecordingStatus? status,
    String? filePath,
    int? durationMs,
    String? error,
  }) {
    return RecorderState(
      status: status ?? this.status,
      filePath: filePath ?? this.filePath,
      durationMs: durationMs ?? this.durationMs,
      error: error,
    );
  }
}
