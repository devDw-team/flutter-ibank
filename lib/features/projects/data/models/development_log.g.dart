// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'development_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DevelopmentLogImpl _$$DevelopmentLogImplFromJson(Map<String, dynamic> json) =>
    _$DevelopmentLogImpl(
      id: json['id'] as String,
      projectId: json['project_id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      logType: $enumDecode(_$DevelopmentLogTypeEnumMap, json['log_type']),
      status: $enumDecode(_$DevelopmentLogStatusEnumMap, json['status']),
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] == null
          ? null
          : DateTime.parse(json['end_date'] as String),
      hoursSpent: (json['hours_spent'] as num?)?.toDouble() ?? 0.0,
      relatedTaskId: json['related_task_id'] as String?,
      attachments: (json['attachments'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      userName: json['userName'] as String?,
      userAvatar: json['userAvatar'] as String?,
      taskTitle: json['taskTitle'] as String?,
    );

Map<String, dynamic> _$$DevelopmentLogImplToJson(
        _$DevelopmentLogImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'project_id': instance.projectId,
      'user_id': instance.userId,
      'title': instance.title,
      'description': instance.description,
      'log_type': _$DevelopmentLogTypeEnumMap[instance.logType]!,
      'status': _$DevelopmentLogStatusEnumMap[instance.status]!,
      'start_date': instance.startDate.toIso8601String(),
      'end_date': instance.endDate?.toIso8601String(),
      'hours_spent': instance.hoursSpent,
      'related_task_id': instance.relatedTaskId,
      'attachments': instance.attachments,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

const _$DevelopmentLogTypeEnumMap = {
  DevelopmentLogType.feature: 'feature',
  DevelopmentLogType.bugfix: 'bugfix',
  DevelopmentLogType.refactor: 'refactor',
  DevelopmentLogType.performance: 'performance',
  DevelopmentLogType.ui: 'ui',
  DevelopmentLogType.backend: 'backend',
  DevelopmentLogType.other: 'other',
};

const _$DevelopmentLogStatusEnumMap = {
  DevelopmentLogStatus.inProgress: 'in_progress',
  DevelopmentLogStatus.completed: 'completed',
  DevelopmentLogStatus.testing: 'testing',
  DevelopmentLogStatus.deployed: 'deployed',
};
