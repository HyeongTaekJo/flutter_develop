// 또는 둘 다 필요할 경우
import 'dart:convert';     // Codec 사용 목적이라면 이걸 주로 씀
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:erp/common/const/colors.dart';
import 'package:erp/common/const/custom_text_formField.dart';
import 'package:erp/common/layout/default_layout.dart';
import 'package:erp/user/model/user_model.dart';
import 'package:erp/user/provider/user_me_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerStatefulWidget {
  static String get routeName => 'login';

  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  String username = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userMeProvider);

    /// 추후에 추가적으로 만일 로그인 요청하다가 아이디 또는 비밀번호 오류로 인해서
    /// 에러가 발생해서 UserModelError가 발생한 경우 메세지를 띄워주어야 한다.
    print(state.toString());

    return DefaultLayout(
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: SafeArea(
          top: true,
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Title(),
                const SizedBox(height: 16.0,),
                _Subtitle(),
                Image.asset(
                  'asset/img/misc/logo.png',
                  width: MediaQuery.of(context).size.width / 3 * 2,
                ),
                CustomTextFormfield(
                  hintText: '아이디를 입력 해주세요',
                  onChanged: (String value){
                    username = value;
                  },
                ),
                const SizedBox(height: 16.0,),
                CustomTextFormfield(
                  hintText: '비밀번호를 입력 해주세요',
                  onChanged: (String value){
                    password = value;
                  },
                  obscureText: true,
                ),
                const SizedBox(height: 16.0,),
                ElevatedButton(
                  /// 로그인을 한번 누르면 바로 상태가 변경되어서 다시 더 누를수없다 로그인이 완료되기 전까지ㅅ
                  onPressed: state is UserModelLoading ? null :() async {
                    /// userMeProvider의 상태가 변경되기 때문에 알아서 페이지가 넘어간다.
                    ref.read(userMeProvider.notifier).login(
                        username: username,
                        password: password
                    );

                    // ID:비밀번호
                    // final rawString = '$username:$password';
                    // Codec<String, String> stringToBase64 = utf8.fuse(base64);
                    // String token = stringToBase64.encode(rawString);
                    //
                    // final resp = await dio.post(
                    //   'http://$ip/auth/login',
                    //   options: Options(
                    //     headers: {
                    //       'authorization' : 'Basic $token',
                    //     }
                    //   ),
                    // );
                    //
                    // final refresToken = resp.data['refreshToken'];
                    // final accessToken = resp.data['accessToken'];
                    //
                    // /// 상태관리되고 있는 secureStorageProvider
                    // final storage = ref.read(secureStorageProvider);
                    //
                    // storage.write(key: REFRESH_TOKEN_KEY, value: refresToken);
                    // storage.write(key: ACCESS_TOKEN_KEY, value: accessToken);
                    //
                    // Navigator.of(context).push(
                    //   MaterialPageRoute(
                    //     builder: (_) => RootTab(),
                    //   ),
                    // );


                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor : PRIMARY_COLOR,
                      foregroundColor: Colors.white
                  ),
                  child: Text(
                    '로그인',
                  ),
                ),
                TextButton(
                  onPressed: () async {

                  },
                  style: TextButton.styleFrom(
                    foregroundColor : Colors.black,
                  ),
                  child: Text(
                    '회원가입',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      '환영합니다!',
      style: TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ),
    );
  }
}

class _Subtitle extends StatelessWidget {
  const _Subtitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      '이메일과 비밀번호를 입력해서 로그인 해주세요!\n오늘도 성공적인 주문이 되길:)',
      style: TextStyle(
        fontSize: 16,
        color: BODY_TEXT_COLOR,
      ),
    );
  }
}
