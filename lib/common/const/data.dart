import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

const ACCESS_TOKEN_KEY = 'ACCESS_TOKEN';
const REFRESH_TOKEN_KEY = 'REFRESH_TOKEN';

// 포트는 필요에 맞게 수정
const emulatorIp = '10.0.2.2:8080';
const simulatorIp = '127.0.0.1:8080';
const localhost = 'localhost:8080';

final ip = kIsWeb
    ? localhost // 웹은 localhost 또는 API 서버 주소
    : (defaultTargetPlatform == TargetPlatform.iOS
    ? simulatorIp
    : emulatorIp);