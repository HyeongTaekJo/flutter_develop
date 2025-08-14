import 'package:web/web.dart' as web;

String? readCookie(String name) {
  final cookies = web.document.cookie; // 항상 String
  if (cookies.isEmpty) return null; // null 체크 제거

  final prefix = '$name=';
  for (final part in cookies.split(';')) {
    final s = part.trim();
    if (s.startsWith(prefix)) {
      return Uri.decodeComponent(s.substring(prefix.length));
    }
  }
  return null;
}