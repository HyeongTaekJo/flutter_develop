import 'dart:convert';

import 'package:erp/common/const/data.dart';

class DataUtils{
  static DateTime stringToDateTime(String value) {
    try {
      return DateTime.parse(value);
    } catch (e) {
      print(' Invalid date string received: "$value"');
      return DateTime.now(); // 또는 DateTime(1970) 등 기본값
    }
  }

  /// 한 개의 이미지만 변경하는 경우
  static String pathToUrl(String value){
    return 'http://$ip$value';
  }

  /// 리스트 이미지를 변경하는 경우
  static List<String> listPathsToUrls(List paths){
    return paths.map((e) => pathToUrl(e)).toList();
  }

  static String plainToBase64(String plain){
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    String endcoded = stringToBase64.encode(plain);

    return endcoded;
  }

}


