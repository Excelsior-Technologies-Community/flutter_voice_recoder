## 📌 Flutter Voice Recorder Plus
```
Flutter Voice Recorder Plus is a lightweight, simple, and flexible voice recording plugin for Flutter.
It provides an easy-to-use API to record audio, pause, resume, stop recordings, and save files to a custom location on the device.

This package is designed for developers who want full control over recording lifecycle and file storage without UI restrictions.
```

## ✨ Features
```
🎙 Start, pause, resume, and stop audio recording

⏱ Real-time recording duration updates

📂 Custom file save location support

📡 Stream-based recorder state updates

📱 Android support

🧩 Clean and minimal API

🚫 No UI enforced — build your own design

⚡ Lightweight and production-ready
```
## Preview

https://github.com/user-attachments/assets/c2e20117-a01d-4b89-8f56-53bb45c09506

## 📦 Installation
Add the dependency to your pubspec.yaml:
```
dependencies:
  flutter_voice_recoder: ^1.0.0
```
Run:
```
flutter pub get
```

## 🔐 Android Permissions
Add the following permissions to your AndroidManifest.xml:
```
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
    android:maxSdkVersion="28" />
```
## 🚀 Usage
Initialize Recorder
```
final recorder = VoiceRecorder();

await recorder.initialize();

recorder.stateStream.listen((state) {
  print('Recording duration: ${state.durationMs}');
});
```
Start Recording (Custom Path)
```
final path =
    '/storage/emulated/0/Music/VoiceRecorder/recording.m4a';

await recorder.start(filePath: path);
```
Pause Recording
```
await recorder.pause();
```
Resume Recording
```
await recorder.resume();
```
Stop Recording
```
final result = await recorder.stop();

print('Saved at: ${result.filePath}');
print('Duration: ${result.durationMs} ms');
print('Size: ${result.fileSizeBytes} bytes');
```
## 📁 Where Are Recordings Saved?
Recordings are saved to the custom file path you provide while starting the recording.

Example location on Android:
```
/storage/emulated/0/Music/VoiceRecorder/
```
## 📄 License
```
MIT License

Copyright (c) 2025 Excelsior Technologies

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
```
