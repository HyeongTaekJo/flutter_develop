import 'package:erp/common/utils/data_utils.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

/// 로그인하다가 에러가 날 수도 있기 때문에  CursorPagination 모델처럼 상태를 나눠야 하낟

abstract class UserModelBase{}

/// Error 상태
class UserModelError extends UserModelBase {
  final String message;

  UserModelError({required this.message});
}

/// 로딩 상태
class UserModelLoading extends UserModelBase {
}

/// 기본 모델
@JsonSerializable()
class UserModel extends UserModelBase {
  final int id;

  @JsonKey(name: 'nickname')
  final String? nickname;

  final String? email;

  @JsonKey(name: 'login_id')
  final String? loginId;

  final String? phone;

  // 서버가 enum 텍스트(예: "ADMIN")를 주면 String으로 받거나,
  // 앱에서도 enum으로 쓰고 싶으면 커스텀 컨버터를 붙이세요.
  final String role;

  // 서버에 이미지가 없다면 nullable로 두거나 아예 제거
  @JsonKey(name: 'image_url')
  final String? imageUrl;

  UserModel({
    required this.id,
    this.nickname,
    this.email,
    this.loginId,
    this.phone,
    required this.role,
    this.imageUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}