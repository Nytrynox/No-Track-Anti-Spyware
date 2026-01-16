# AI-Powered Anti-Spyware for Mobile Devices

An MVP Flutter application demonstrating an AI-driven anti-spyware concept: real-time monitoring, on-demand scans, and a threat log. It simulates on-device ML analysis to detect behavioral anomalies and notify users.

Title: "AI-Powered Anti-Spyware for Mobile Devices: A Novel Approach to Enhanced Security"

Abstract: In the era of ubiquitous mobile computing, the threat of spyware to personal data and device security has escalated. This app showcases an AI assistant that analyzes device behavior, identifies anomalies, and predicts potential threats, providing real-time protection against evolving spyware threats.

Keywords: AI-powered security, anti-spyware, mobile security, machine learning, threat detection.

## Features
- Dashboard with threat overview (severity distribution)
- On-demand scan and continuous monitoring
- Threat log with mitigation actions
- Local notifications on supported platforms
 - Heuristic+ML engine with installed-app inspection (Android)

## Run
Prereqs: Flutter SDK. For quickest try, run on Web or Android/iOS simulators/devices.

```sh
# From project root
flutter pub get

# Web (requires Chrome installed)
flutter run -d chrome

# iOS Simulator (needs Xcode)
flutter run -d ios

# Android Emulator/device
flutter run -d android
```

If desktop platforms are enabled in your Flutter, you can also add macOS with:

```sh
flutter config --enable-macos-desktop
flutter create .
flutter run -d macos
```

## Notes
- The AI analysis is mocked in `lib/services/ai_analyzer.dart` for demo purposes.
- Notification support is disabled on Web intentionally.
 - The AI engine in `lib/services/ai_engine.dart` combines heuristics with optional TFLite inference.
 - App inspection uses `device_apps` on Android via `DefaultAppInspector`; other platforms return empty lists.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
