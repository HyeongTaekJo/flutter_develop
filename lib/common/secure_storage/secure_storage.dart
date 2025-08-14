import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// 이 프로젝트에서 계속 동일한 FlutterSecureStorage를 사용하기 위한 provider
/// interceptor, 로그인 등에서 사용하기 때문에 provider로 만든다.
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) => FlutterSecureStorage());