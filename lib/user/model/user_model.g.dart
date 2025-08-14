// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: (json['id'] as num).toInt(),
      nickname: json['nickname'] as String?,
      email: json['email'] as String?,
      loginId: json['login_id'] as String?,
      phone: json['phone'] as String?,
      role: json['role'] as String,
      imageUrl: json['image_url'] as String?,
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'nickname': instance.nickname,
      'email': instance.email,
      'login_id': instance.loginId,
      'phone': instance.phone,
      'role': instance.role,
      'image_url': instance.imageUrl,
    };
