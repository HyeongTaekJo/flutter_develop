// lib/common/env/client_env.dart
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

enum AppPlatform { web, android, ios, macos, windows, linux, fuchsia }

class ClientEnv {
  final AppPlatform platform;
  final String deviceId;
  final String appVersion;

  ClientEnv({
    required this.platform,
    required this.deviceId,
    required this.appVersion,
  });

  static AppPlatform detectPlatform() {
    if (kIsWeb) return AppPlatform.web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android: return AppPlatform.android;
      case TargetPlatform.iOS:     return AppPlatform.ios;
      case TargetPlatform.macOS:   return AppPlatform.macos;
      case TargetPlatform.windows: return AppPlatform.windows;
      case TargetPlatform.linux:   return AppPlatform.linux;
      case TargetPlatform.fuchsia: return AppPlatform.fuchsia;
    }
  }

  String get platformString => platform.name; // 'web' 등
}
