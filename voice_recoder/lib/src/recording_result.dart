class RecordingResult {
  final String filePath;
  final int durationMs;
  final int fileSizeBytes;
  final String mimeType;
  final String format;

  RecordingResult({
    required this.filePath,
    required this.durationMs,
    required this.fileSizeBytes,
    required this.mimeType,
    required this.format,
  });
}
