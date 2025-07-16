// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProjectModelImpl _$$ProjectModelImplFromJson(Map<String, dynamic> json) =>
    _$ProjectModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      status: $enumDecodeNullable(_$ProjectStatusEnumMap, json['status']) ??
          ProjectStatus.planning,
      ownerId: json['owner_id'] as String,
      startDate: json['start_date'] == null
          ? null
          : DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] == null
          ? null
          : DateTime.parse(json['end_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      members: (json['members'] as List<dynamic>?)
              ?.map(
                  (e) => ProjectMemberModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      ownerName: json['ownerName'] as String?,
      ownerEmail: json['ownerEmail'] as String?,
    );

Map<String, dynamic> _$$ProjectModelImplToJson(_$ProjectModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'status': _$ProjectStatusEnumMap[instance.status]!,
      'owner_id': instance.ownerId,
      'start_date': instance.startDate?.toIso8601String(),
      'end_date': instance.endDate?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'members': instance.members,
      'ownerName': instance.ownerName,
      'ownerEmail': instance.ownerEmail,
    };

const _$ProjectStatusEnumMap = {
  ProjectStatus.planning: 'planning',
  ProjectStatus.active: 'active',
  ProjectStatus.onHold: 'on_hold',
  ProjectStatus.completed: 'completed',
  ProjectStatus.cancelled: 'cancelled',
};

_$ProjectMemberModelImpl _$$ProjectMemberModelImplFromJson(
        Map<String, dynamic> json) =>
    _$ProjectMemberModelImpl(
      id: json['id'] as String,
      projectId: json['project_id'] as String,
      userId: json['user_id'] as String,
      role: $enumDecodeNullable(_$ProjectMemberRoleEnumMap, json['role']) ??
          ProjectMemberRole.member,
      joinedAt: DateTime.parse(json['joined_at'] as String),
      userName: json['userName'] as String?,
      userEmail: json['userEmail'] as String?,
      userAvatar: json['userAvatar'] as String?,
    );

Map<String, dynamic> _$$ProjectMemberModelImplToJson(
        _$ProjectMemberModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'project_id': instance.projectId,
      'user_id': instance.userId,
      'role': _$ProjectMemberRoleEnumMap[instance.role]!,
      'joined_at': instance.joinedAt.toIso8601String(),
      'userName': instance.userName,
      'userEmail': instance.userEmail,
      'userAvatar': instance.userAvatar,
    };

const _$ProjectMemberRoleEnumMap = {
  ProjectMemberRole.owner: 'owner',
  ProjectMemberRole.manager: 'manager',
  ProjectMemberRole.member: 'member',
  ProjectMemberRole.viewer: 'viewer',
};
