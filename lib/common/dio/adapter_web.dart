import 'package:dio/dio.dart';
import 'package:dio/adapter_browser.dart';

HttpClientAdapter createAdapter() {
  final a = BrowserHttpClientAdapter();
  a.withCredentials = true; // 쿠키 주고받기 허용
  return a;
}
