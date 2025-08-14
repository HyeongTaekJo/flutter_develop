import 'package:dio/dio.dart';
import 'package:erp/common/const/data.dart';
import 'package:erp/common/provider/client_env_provider.dart';
import 'package:erp/common/secure_storage/secure_storage.dart';
import 'package:erp/user/provider/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:erp/common/env/client_env.dart';
import 'package:erp/common/dio/adapter_io.dart'
  if (dart.library.html) 'package:erp/common/dio/adapter_web.dart';

/// dioProvider를 불러오면 동일한 dio와 storage를 불러와서 사용할 수 있다.
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio();

  //  플랫폼별 어댑터 자동 적용 (웹이면 withCredentials=true)
  // 웹 빌드(Flutter Web)일 때만 dart.library.html이 정의돼요 → 그래서 adapter_web.dart가 선택됩니다.
  dio.httpClientAdapter = createAdapter();

  final storage = ref.watch(secureStorageProvider);

  dio.interceptors.add(
    CustomInterceptor(
      storage: storage,
      ref: ref,
    ),
  );

  return dio;
});

class CustomInterceptor extends Interceptor{
  final FlutterSecureStorage storage;
  final Ref ref;

  // 환경 캐시(최초 1회 로딩)
  ClientEnv? _envCache;

  CustomInterceptor({
    required this.storage,
    required this.ref,
  });

  //1. 요청이 보내질때마다 만약에 header에 accessToken true가 있으면  토큰으로 변경
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async{
    print('[REQ] ${options.method} ${options.uri}');

    _envCache ??= await ref.read(clientEnvProvider.notifier).waitForEnv();
    final env = _envCache!;

    // 공통: 플랫폼/버전 헤더(선택)
    options.headers.addAll({
      'X-Client-Type': env.platformString, // web/android/ios/...
      'x-app-version': env.appVersion,
    });

    // 웹/앱 분기
    if (env.platform != AppPlatform.web) {
      //  앱: 헤더로 did 전달
      // X-Device-Key는 보내지 않음
      // 서버가 X-Client-Type == 'web'이면 쿠키(browser_id)로 DID 처리
      final deviceKey = 'app:${env.platformString}:${env.deviceId}';
      options.headers['X-Device-Key'] = deviceKey;

      // (선택) 네이티브에서만 User-Agent 커스텀
      options.headers['User-Agent'] = 'MyApp/${env.appVersion} (${env.platformString})';
    }

    // (B) 토큰 주입 로직
    if(options.headers['accessToken'] == 'true'){
      options.headers.remove('accessToken');

      final token = await storage.read(key: ACCESS_TOKEN_KEY);

      options.headers.addAll({
        'authorization' : 'Bearer $token',
      });
    }


    if(options.headers['refreshToken'] == 'true'){
      options.headers.remove('refreshToken');

      final token = await storage.read(key: REFRESH_TOKEN_KEY);

      options.headers.addAll({
        'authorization' : 'Bearer $token',
      });
    }

    return super.onRequest(options, handler);
  }

  /// 2. 응답을 받았을 때(정상적으로 작동했을 때만 옴)
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('[RES] ${response.requestOptions.method} ${response.requestOptions.uri}');

    return super.onResponse(response, handler);
  }


  // 3. 에러가 났을 때
  // 401에러가 났을때 토큰을 재발급받는 시도를 하고 토큰을 재발급하면
  // 다시 새로운 토큰으로 요쳥을 한다.
  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    print('[REQ] ${err.requestOptions.method} ${err.requestOptions.uri}');

    final refreshToken = await storage.read(key: REFRESH_TOKEN_KEY);

    // refreshToken이 없으면 에러를 던진다.
    if(refreshToken == null){
      // 에러 생성하기(handler.reject)
      return handler.reject(err);
    }

    final isStatus401 = err.response?.statusCode == 401;

    ///  isPathRefresh가 false면 refreshToken을 가지고 토큰을 재생성하려다가 에러가 난거라서
    /// refreshToken 자체에 error가 있다는 것이므로 에러를 던지면 된다.
    final isPathRefresh = err.requestOptions.path == '/auth/token/access';

    /// 아래 로직은 다시 재발급하는 로직이 아니다.
    if(isStatus401 && !isPathRefresh){
      // 플랫폼별 어댑터 적용 (웹이면 withCredentials=true)
      final retry = Dio()..httpClientAdapter = createAdapter();

      try{
        final resp = await retry.post(
          'http://$ip/auth/token/access',
          options: Options(
              headers: {
                'authorization' : 'Bearer $refreshToken',
              }
          ),
        );

        // 토큰 변경하기
        final accessToken = resp.data['accessToken'];

        // 요청 옵션 가져오기
        final options = err.requestOptions;

        options.headers.addAll({
          'authorization' : 'Bearer $accessToken',
        });

        // storage에도 저장해줘야 한다.
        await storage.write(key: ACCESS_TOKEN_KEY, value: accessToken);

        // 재시도 전에도 환경 헤더를 보장하고 싶다면 여기서도 첨부(선택)
        if (_envCache != null) {
          options.headers.addAll({
            'x-client-platform': _envCache!.platformString,
            'x-device-id': _envCache!.deviceId,
            'x-app-version': _envCache!.appVersion,
          });
        }

        /// 원래 요청을 토큰만 변경시킨 상태에서 다시 요청
        final response = await retry.fetch(options);

        /// 여기서 토큰을 바꾼 것을 실제 요청보내는 곳(에러가 발생하지 않은 것처럼 됨)
        return handler.resolve(response);
      }on DioError catch(e){
        print('에러 상태 코드: ${e.response?.statusCode}');
        print('에러 응답 본문: ${e.response?.data}');

        /// 만일 refresh과정에서 에러가 났을때 어떠한 상황이던 토큰을 재발급 받을 상황이 아니다.
        return handler.reject(e);
      }
    }

    /// 만일 refresh토큰까지도 만료되어서 로그아웃 해야하는 경우
    ref.read(authProvider.notifier).logout();

    /// 에러 발생시키기
    return handler.reject(err);
  }
}