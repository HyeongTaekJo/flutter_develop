import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 플랫폼 정보를 담는 모델
class PlatformInfo {
  final bool isWeb;
  final bool isAndroid;
  final bool isIOS;
  final bool isDesktop;
  final TargetPlatform? targetPlatform;

  const PlatformInfo({
    required this.isWeb,
    required this.isAndroid,
    required this.isIOS,
    required this.isDesktop,
    this.targetPlatform,
  });

  @override
  String toString() {
    return 'PlatformInfo(isWeb: $isWeb, isAndroid: $isAndroid, isIOS: $isIOS, isDesktop: $isDesktop, targetPlatform: $targetPlatform)';
  }
}

// 플랫폼 감지 Provider
final platformProvider = Provider<PlatformInfo>((ref) {
  final bool isWeb = kIsWeb;
  final bool isAndroid = !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  final bool isIOS = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
  final bool isDesktop = !kIsWeb && (
      defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.linux
  );

  return PlatformInfo(
    isWeb: isWeb,
    isAndroid: isAndroid,
    isIOS: isIOS,
    isDesktop: isDesktop,
    targetPlatform: kIsWeb ? null : defaultTargetPlatform,
  );
});

// 편의를 위한 개별 Provider들 (필요시 사용)
final isWebProvider = Provider<bool>((ref) {
  return ref.watch(platformProvider).isWeb;
});

final isAndroidProvider = Provider<bool>((ref) {
  return ref.watch(platformProvider).isAndroid;
});

final isIOSProvider = Provider<bool>((ref) {
  return ref.watch(platformProvider).isIOS;
});

final isDesktopProvider = Provider<bool>((ref) {
  return ref.watch(platformProvider).isDesktop;
});

/// 사용 예시
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:untitled/common/provider/platform_provider.dart';
//
// // 예시 1: Widget에서 플랫폼 정보 사용
// class PlatformAwareWidget extends ConsumerWidget {
//   const PlatformAwareWidget({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final platform = ref.watch(platformProvider);
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(platform.isWeb ? 'Web App' : 'Mobile App'),
//       ),
//       body: Column(
//         children: [
//           Text('Current Platform: ${platform.toString()}'),
//
//           // 플랫폼에 따른 다른 UI 렌더링
//           if (platform.isWeb)
//             _buildWebUI()
//           else if (platform.isAndroid)
//             _buildAndroidUI()
//           else if (platform.isIOS)
//               _buildIOSUI()
//             else
//               _buildDesktopUI(),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildWebUI() {
//     return Container(
//       padding: EdgeInsets.all(20),
//       child: Text('Web specific UI'),
//     );
//   }
//
//   Widget _buildAndroidUI() {
//     return Container(
//       padding: EdgeInsets.all(20),
//       child: Text('Android specific UI'),
//     );
//   }
//
//   Widget _buildIOSUI() {
//     return Container(
//       padding: EdgeInsets.all(20),
//       child: Text('iOS specific UI'),
//     );
//   }
//
//   Widget _buildDesktopUI() {
//     return Container(
//       padding: EdgeInsets.all(20),
//       child: Text('Desktop specific UI'),
//     );
//   }
// }
//
// // 예시 2: StateNotifier에서 플랫폼 정보 사용
// class SomeStateNotifier extends StateNotifier<String> {
//   final Ref ref;
//
//   SomeStateNotifier(this.ref) : super('initial');
//
//   void someAction() {
//     final platform = ref.read(platformProvider);
//
//     if (platform.isWeb) {
//       // 웹에서만 실행할 로직
//       state = 'Web action performed';
//     } else {
//       // 모바일/데스크톱에서만 실행할 로직
//       state = 'Mobile/Desktop action performed';
//     }
//   }
// }
//
// final someStateProvider = StateNotifierProvider<SomeStateNotifier, String>((ref) {
//   return SomeStateNotifier(ref);
// });
//
// // 예시 3: 간단한 플랫폼 체크만 필요한 경우
// class SimpleCheckWidget extends ConsumerWidget {
//   const SimpleCheckWidget({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final isWeb = ref.watch(isWebProvider);
//     final isAndroid = ref.watch(isAndroidProvider);
//
//     return Column(
//       children: [
//         Text('Is Web: $isWeb'),
//         Text('Is Android: $isAndroid'),
//       ],
//     );
//   }
// }
//
// // 예시 4: Repository나 Service에서 사용
// class ApiService {
//   final Ref ref;
//
//   ApiService(this.ref);
//
//   Future<String> getData() async {
//     final platform = ref.read(platformProvider);
//
//     // 플랫폼에 따른 다른 API 엔드포인트 호출
//     final endpoint = platform.isWeb
//         ? '/api/web/data'
//         : '/api/mobile/data';
//
//     // API 호출 로직...
//     return 'Data from $endpoint';
//   }
// }
//
// final apiServiceProvider = Provider<ApiService>((ref) {
//   return ApiService(ref);
// });
//
// // 예시 5: userMeProvider와 동일한 방식으로 사용
// class LoginWidget extends ConsumerWidget {
//   const LoginWidget({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final platform = ref.watch(platformProvider);
//
//     return ElevatedButton(
//       onPressed: () {
//         // 로그인 로직에서 플랫폼 정보 사용
//         if (platform.isWeb) {
//           print('웹에서 로그인 시도');
//           // 웹 전용 로그인 로직
//         } else {
//           print('앱에서 로그인 시도');
//           // 앱 전용 로그인 로직
//         }
//       },
//       child: Text(platform.isWeb ? 'Web Login' : 'App Login'),
//     );
//   }
// }