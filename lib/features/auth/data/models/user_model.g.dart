// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserModelImpl _$$UserModelImplFromJson(Map<String, dynamic> json) =>
    _$UserModelImpl(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      phone: json['phone'] as String?,
      division: json['division'] as String?,
      department: json['department'] as String?,
      position: json['position'] as String?,
      status: json['status'] as String?,
      birthday: json['birthday'] as String?,
      joindate: json['joindate'] as String?,
      role: json['role'] as String? ?? 'user',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$UserModelImplToJson(_$UserModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'name': instance.name,
      'avatar_url': instance.avatarUrl,
      'phone': instance.phone,
      'division': instance.division,
      'department': instance.department,
      'position': instance.position,
      'status': instance.status,
      'birthday': instance.birthday,
      'joindate': instance.joindate,
      'role': instance.role,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
