import 'package:erp/common/view/root_tab.dart';
import 'package:erp/common/view/splash_screen.dart';
import 'package:erp/user/provider/auth_provider.dart';
import 'package:erp/user/view/login_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';


final routerProvider = Provider<GoRouter>((ref) {
  // watch - 값이 변경될 때 마다 다시 빌드
  // read - 한번만 읽고 값이 변경돼도 다시 빌드하지 않음
  final provider = ref.read(authProvider); // AuthProvider 가져오기

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) => provider.redirectLogic(state),
    refreshListenable: provider, // authProvider 상태 변경 시 redirect를 다시 평가
    routes: [
      GoRoute(
        path: '/',
        name: RootTab.routeName,
        builder: (context, state) => const RootTab(),
        // routes: [
        //   GoRoute(
        //     path: 'restaurant/:id',
        //     name: RestaurantDetailScreen.routeName,
        //     builder: (context, state) {
        //       final id = state.pathParameters['id']!;
        //       return RestaurantDetailScreen(id: id);
        //     },
        //   ),
        // ],
      ),
      // GoRoute( // 마지막 결제하는 창이라서 밑으로 화면이 없다.
      //   path: '/order_done',
      //   name: OrderDoneScreen.routeName,
      //   builder: (context, state) => const OrderDoneScreen(),
      // ),
      // GoRoute(
      //   path: '/basket',
      //   name: BasketScreen.routeName,
      //   builder: (context, state) => const BasketScreen(),
      // ),
      GoRoute(
        path: '/splash',
        name: SplashScreen.routeName,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: LoginScreen.routeName,
        builder: (context, state) => const LoginScreen(),
      ),
    ],
  );
});