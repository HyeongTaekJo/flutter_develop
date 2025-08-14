import 'package:dio/dio.dart';
import 'package:dio/adapter.dart';

HttpClientAdapter createAdapter() {
  // 기본 IO 어댑터 (모바일/데스크톱)
  return DefaultHttpClientAdapter();
}
