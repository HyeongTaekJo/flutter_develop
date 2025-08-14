import 'package:dio/dio.dart';
import 'package:erp/common/const/data.dart';
import 'package:erp/common/dio/dio.dart';
import 'package:erp/common/model/login_response.dart';
import 'package:erp/common/model/token_response.dart';
import 'package:erp/common/utils/data_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final authRepositoryProvider = Provider<AuthRepository>(
        (ref) {
      final dio = ref.watch(dioProvider);

      return AuthRepository(
          baseUrl: 'http://$ip/auth',
          dio: dio
      );
    }
);

class AuthRepository {
  final String baseUrl;
  final Dio dio;

  AuthRepository({
    required this.baseUrl,
    required this.dio,
  });

  /// 로그인 로직
  Future<LoginResponse> login({
    required String username,
    required String password,
  }) async {

    final serialized = DataUtils.plainToBase64('$username:$password');

    final resp = await dio.post(
      '$baseUrl/login/login_id',
      options: Options(
          headers: {
            'authorization' : 'Basic $serialized',
          }
      ),
    );

    return LoginResponse.fromJson(resp.data);
  }

  /// 서버 로그아웃 (세션/리프레시 정리 + 쿠키 삭제)
  Future<void> logout() async {
    await dio.post(
      '$baseUrl/logout',
      options: Options(
        headers: {
          'accessToken': 'true', // ← 인터셉터가 Bearer 토큰 붙이도록
        },
        // 웹에서 HttpOnly 쿠키(예: refresh_token) 삭제까지 하려면,
        // dioProvider에서 withCredentials 활성화(권장). 개별 요청으로 강제하려면:
        // extra: {'withCredentials': true},
      ),
    );
  }

  /// 토큰 갱신 로직
  Future<TokenResponse> token() async {
    final resp = await dio.post(
      '$baseUrl/token',
      options: Options(
          headers: {
            'refreshToken' : 'true', //dio에 interceptor 다 해놔서 토큰 알아서 교체해줌
          }
      ),
    );

    return TokenResponse.fromJson(resp.data);
  }
}
