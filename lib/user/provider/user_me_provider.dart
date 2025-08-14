import 'package:erp/common/const/data.dart';
import 'package:erp/common/env/client_env.dart';
import 'package:erp/common/provider/client_env_provider.dart';
import 'package:erp/common/secure_storage/secure_storage.dart';
import 'package:erp/user/model/user_model.dart';
import 'package:erp/user/repository/auth_repository.dart';
import 'package:erp/user/repository/user_me_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:erp/common/cookie/web_cookie_stub.dart'
  if (dart.library.html) 'package:erp/common/cookie/web_cookie_web.dart';

final userMeProvider = StateNotifierProvider<UserMeStateNotifier, UserModelBase?> (
        (ref) {
      final authRepository = ref.watch(authRepositoryProvider);
      final userMeRepository = ref.watch(userMeRepositoryProvider);
      final storage = ref.watch(secureStorageProvider);

      return UserMeStateNotifier(
          repository: userMeRepository,
          storage: storage,
          authRepository: authRepository,
          ref: ref
      );
    }
);

class UserMeStateNotifier extends StateNotifier<UserModelBase?> {
  final Ref ref;
  final AuthRepository authRepository;
  final UserMeRepository repository;
  final FlutterSecureStorage storage;

  UserMeStateNotifier({
    required this.ref,
    required this.repository,
    required this.storage,
    required this.authRepository,
  }) : super(UserModelLoading()){
    // 내 정보 가져오기
    // UserMeStateNotifier 클래스가 인스턴스화가 되면 바로
    // getMe를 호출해서 user 데이터를 상태로 가지고 있을 것이다.
    getMe();
  }

  /// user 정보 가져오기
  Future<void> getMe() async {
    // 플랫폼 확인
    final env = await ref.read(clientEnvProvider.notifier).waitForEnv();
    final isWeb = env.platform == AppPlatform.web;

    // accessToken은 공통: storage에서
    final accessToken = await storage.read(key: ACCESS_TOKEN_KEY);

    // refreshToken은 분기: 웹=쿠키, 앱=storage
    final String? refreshToken;
    if (isWeb) {
      // 쿠키 키는 서버 설정에 맞게 둘 다 시도 (필요한 쪽만 남겨도 됨)
      refreshToken = readCookie('refresh_token') ?? readCookie('refreshToken');
    } else {
      refreshToken = await storage.read(key: REFRESH_TOKEN_KEY);
    }

    /// accessToken, refreshToken 둘 중 하나만 없어도 아래 getMe를 실행할 필요가 없다.
    /// 이유는 로그인이 제대로 이루어지지 않은 상태니까
    if (refreshToken == null || accessToken == null) {
      state = null; // 비로그인
      return;
    }

    try {
      final resp = await repository.getMe();
      state = resp; // 로그인 상태
    } catch (e) {
      //  반드시 상태 갱신해서 redirect가 동작하도록
      state = UserModelError(message: '서버의 세션이 만료되었거나 인증에 실패했습니다.');
    }
  }

  /// 로그인이 될 수 도있고 안될 수도있기 때문에 UserModelBase타입으로 반환한다고 한 것이다.
  Future<UserModelBase> login({
    required String username,
    required String password,
  }) async {
    try{
      state = UserModelLoading();

      final resp = await authRepository.login(
          username: username,
          password: password
      );

      /// 브라우저에서 로그인하면 서버에서 refreshToken을 아예 안보내준다. (쿠키에만 있음)
      await storage.write(key: REFRESH_TOKEN_KEY, value: resp.refreshToken);
      await storage.write(key: ACCESS_TOKEN_KEY, value: resp.accessToken);

      /// 로그인을 했고 토큰을 발급 받았더라도 유효한 토큰인지 아니면
      /// 누가 강제로 아무거나 넣었을 수 도 있기 때문이다 그래서
      /// 한번 더 user정보를 서버에서 가져와보면 토큰이 유효하다는 것을 알 수 있다.
      final userResp = await repository.getMe();

      ///userResp은  repository.getMe(); 여기에서 값을 가져오면 다시 UserModel 상태로 변경된다.
      ///즉, UserModelLoading 상태였던것을 다시 UserModel 상태로 바꿔주게 된다.
      state = userResp;

      /// 혹시 로그인하고 데이터를 가져다가 사용할 수 있으니까 리턴해준다.
      return userResp;
    }catch(e){
      state = UserModelError(
        /// 사실 username이 잘못된건지 password가 잘못된건지 자세히 적어줘야 한다.
          message: '로그인에 실패했습니다.'
      );

      return Future.value(state);
    }
  }

  // 로그아웃
  Future<void> logout() async {
    // 즉시 바로 상태를 null로 만들고 로그인 페이지로 보내 버리면 된다.
    // 어떠한 작업을 하기 전에 걍 바로 로그아웃해버리기
    // 상태가 null이 되는 순간 redirect가 작동한다
    // authProvider가 userMeProvider을 liten 하고 있기 때문에
    state = null;

    // 2) 서버 로그아웃 (실패해도 로컬 정리는 진행)
    try {
      await authRepository.logout();
    } catch (_) {}

    // 3) 로컬 토큰 삭제
    await Future.wait([
      storage.delete(key: REFRESH_TOKEN_KEY),
      storage.delete(key: ACCESS_TOKEN_KEY),
    ]);
  }
}