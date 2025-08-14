import 'package:erp/user/model/user_model.dart';
import 'package:erp/user/provider/user_me_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';


final authProvider = ChangeNotifierProvider<AuthProvider>(
        (ref){
      return AuthProvider(ref:ref);
    }
);

class AuthProvider extends ChangeNotifier{
  final Ref ref;

  AuthProvider({
    required this.ref,
  }){
    /// userMeProvider의 상태가 UserModelLoading인지 UserModelError인지 user데이터가 존재하는지 알 수 있다.
    ref.listen<UserModelBase?>(userMeProvider, (previous, next){
      if(previous != next){
        /// 변경 사항이 있을 때만 authProvider에게 변경 사항을 알려준다.
        notifyListeners();
      }
    });
  }

  /// SplashScreen
  /// 앱을 처음 시작했을 때
  /// 토큰이 존재하는지 확인하고
  /// 로그인 스크린으로 보내줄지
  /// 홈 스크린으로 보내줄지 확인하는 과정이 필요하다.
  String? redirectLogic(GoRouterState state){
    ///user 상태 보기
    final UserModelBase? user = ref.read(userMeProvider);

    /// 로그인중
    final logginIn = state.location == '/login';

    /// 유저 정보가 없는데 로그인중이면
    /// 그대로 로그인 페이지에 두고
    /// 만약에 로그인중이 아니라면 로그인 페이지로 이동
    if(user == null){
      return logginIn ? null : '/login';
    }

    /// user가 null이 아님

    /// userModel
    /// 사용자 정보가 있는 상태면
    /// 로그인 중이거나 현재 위치가 splashScreen이면
    /// 홈으로 이동
    if(user is UserModel){
      return logginIn || state.location == '/splash' ? '/' : null;
    }

    /// UserModelError
    if(user is UserModelError){
      /// 추가로 로그아웃까지 시키면 더 좋다.
      return !logginIn ? '/login' : null;
    }

    /// 원래 가던곳으로 가라
    return null;
  }

  /// dio provider에서 사용하는 logout이다.
  /// dio에서 바로 ref.read(userMeProvider.notifier).logout(); 이렇게하면
  /// dio와 userMeProvider에서 사용하는 dio가 꼬이게 되어서 별도의 logout이 필요하다.
  void logout(){
    ref.read(userMeProvider.notifier).logout();
  }
}