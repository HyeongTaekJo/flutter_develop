// lib/common/env/client_env_provider.dart
import 'dart:async';
import 'package:erp/common/model/client_env_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:erp/common/env/app_version.dart';
import 'package:erp/common/env/client_env.dart';
import 'package:erp/common/env/device_id.dart';
import 'package:erp/common/secure_storage/secure_storage.dart';

final clientEnvProvider = StateNotifierProvider<ClientEnvNotifier, ClientEnvBase>(
      (ref) => ClientEnvNotifier(ref),
);

class ClientEnvNotifier extends StateNotifier<ClientEnvBase> {
  final Ref ref;
  Completer<ClientEnv>? _ready;

  ClientEnvNotifier(this.ref) : super(ClientEnvLoading()) {
    _init();
  }

  Future<void> _init() async {
    // 🔧 새 초기화 시작마다 Completer 새로 생성
    _ready = Completer<ClientEnv>();

    try {
      final platform = ClientEnv.detectPlatform();
      final FlutterSecureStorage storage = ref.read(secureStorageProvider);
      final deviceId = await DeviceId.getOrCreate(storage: storage);
      final version  = await getAppVersion();

      final env = ClientEnv(
        platform: platform,
        deviceId: deviceId,
        appVersion: version,
      );

      state = ClientEnvLoaded(env);

      //  대기 중인 쪽에 완료 신호
      if (!(_ready?.isCompleted ?? true)) {
        _ready!.complete(env);
      }
    } catch (e) {
      state = ClientEnvError('클라이언트 환경 초기화 실패: $e');

      //  에러도 반드시 completeError
      if (!(_ready?.isCompleted ?? true)) {
        _ready!.completeError(e);
      }
    }
  }

  Future<void> refresh() => _init();

  /// env가 준비되었을 때까지 기다렸다가 반환
  Future<ClientEnv> waitForEnv() async {
    final s = state;
    if (s is ClientEnvLoaded) return s.env;

    // 🔧 _ready가 null일 가능성 방지 (이상 상태에도 대비)
    if (_ready == null) {
      // 초기화가 아직 한 번도 안 돌았거나, 예외로 끊겼을 수 있음 → 재시도
      await _init();
    }
    return _ready!.future;
  }
}
