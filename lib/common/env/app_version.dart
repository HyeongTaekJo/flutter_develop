// lib/common/env/app_version.dart
import 'package:package_info_plus/package_info_plus.dart';

Future<String> getAppVersion() async {
  try {
    final info = await PackageInfo.fromPlatform();
    return '${info.version}+${info.buildNumber}';
  } catch (_) {
    return 'unknown';
  }
}