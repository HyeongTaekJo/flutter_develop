import 'package:json_annotation/json_annotation.dart';

part 'login_response.g.dart';

@JsonSerializable()
class LoginResponse {
  final String accessToken;
  final String? refreshToken; // ← 웹일 땐 null 가능

  LoginResponse({
    required this.accessToken,
    this.refreshToken,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json)
  => _$LoginResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}