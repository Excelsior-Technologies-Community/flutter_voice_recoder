/// Audio format types supported by the recorder
enum AudioFormat {
  aac,
  wav,
  mp3,
  m4a,
}

/// Audio quality presets
enum AudioQuality {
  low,     // 32 kbps
  medium,  // 64 kbps
  high,    // 128 kbps
  veryHigh // 256 kbps
}

/// Configuration class for audio recording
class AudioConfig {
  /// Audio format to record in
  final AudioFormat format;

  /// Sample rate in Hz (8000, 16000, 44100, 48000)
  final int sampleRate;

  /// Bit rate in bits per second
  final int bitRate;

  /// Number of audio channels (1 = mono, 2 = stereo)
  final int channels;

  /// Enable echo cancellation
  final bool echoCancellation;

  /// Enable noise suppression
  final bool noiseSuppression;

  /// Enable automatic gain control
  final bool autoGainControl;

  const AudioConfig({
    this.format = AudioFormat.aac,
    this.sampleRate = 44100,
    this.bitRate = 128000,
    this.channels = 1,
    this.echoCancellation = true,
    this.noiseSuppression = true,
    this.autoGainControl = true,
  });

  /// Create config from quality preset
  factory AudioConfig.fromQuality(AudioQuality quality, {AudioFormat? format}) {
    int bitRate;
    int sampleRate;

    switch (quality) {
      case AudioQuality.low:
        bitRate = 32000;
        sampleRate = 16000;
        break;
      case AudioQuality.medium:
        bitRate = 64000;
        sampleRate = 22050;
        break;
      case AudioQuality.high:
        bitRate = 128000;
        sampleRate = 44100;
        break;
      case AudioQuality.veryHigh:
        bitRate = 256000;
        sampleRate = 48000;
        break;
    }

    return AudioConfig(
      format: format ?? AudioFormat.aac,
      sampleRate: sampleRate,
      bitRate: bitRate,
    );
  }

  /// Convert to map for platform channel
  Map<String, dynamic> toMap() {
    return {
      'format': format.name,
      'sampleRate': sampleRate,
      'bitRate': bitRate,
      'channels': channels,
      'echoCancellation': echoCancellation,
      'noiseSuppression': noiseSuppression,
      'autoGainControl': autoGainControl,
    };
  }

  /// Get file extension for the format
  String get fileExtension {
    switch (format) {
      case AudioFormat.aac:
        return 'aac';
      case AudioFormat.wav:
        return 'wav';
      case AudioFormat.mp3:
        return 'mp3';
      case AudioFormat.m4a:
        return 'm4a';
    }
  }

  AudioConfig copyWith({
    AudioFormat? format,
    int? sampleRate,
    int? bitRate,
    int? channels,
    bool? echoCancellation,
    bool? noiseSuppression,
    bool? autoGainControl,
  }) {
    return AudioConfig(
      format: format ?? this.format,
      sampleRate: sampleRate ?? this.sampleRate,
      bitRate: bitRate ?? this.bitRate,
      channels: channels ?? this.channels,
      echoCancellation: echoCancellation ?? this.echoCancellation,
      noiseSuppression: noiseSuppression ?? this.noiseSuppression,
      autoGainControl: autoGainControl ?? this.autoGainControl,
    );
  }
}