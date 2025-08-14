// lib/common/env/device_id.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

const _kDeviceIdKey = 'device_id';

class DeviceId {
  static Future<String> getOrCreate({
    FlutterSecureStorage? storage,
  }) async {
    if (kIsWeb) {
      final sp = await SharedPreferences.getInstance();
      var id = sp.getString(_kDeviceIdKey);
      if (id == null) {
        id = const Uuid().v4();
        await sp.setString(_kDeviceIdKey, id);
      }
      return id;
    } else {
      final s = storage ?? const FlutterSecureStorage(); // ← fallback
      var id = await s.read(key: _kDeviceIdKey);
      if (id == null) {
        id = const Uuid().v4();
        await s.write(key: _kDeviceIdKey, value: id);
      }
      return id;
    }
  }
}
