// lib/common/env/client_env_state.dart
import 'package:erp/common/env/client_env.dart';

/// 베이스
abstract class ClientEnvBase {}

/// 로딩
class ClientEnvLoading extends ClientEnvBase {}

/// 에러
class ClientEnvError extends ClientEnvBase {
  final String message;
  ClientEnvError(this.message);
}

/// 성공(데이터 보유)
class ClientEnvLoaded extends ClientEnvBase {
  final ClientEnv env;
  ClientEnvLoaded(this.env);
}
