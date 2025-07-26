import 'package:freezed_annotation/freezed_annotation.dart';

part 'development_log.freezed.dart';
part 'development_log.g.dart';

@freezed
class DevelopmentLog with _$DevelopmentLog {
  const factory DevelopmentLog({
    required String id,
    @JsonKey(name: 'project_id') required String projectId,
    @JsonKey(name: 'user_id') required String userId,
    required String title,
    String? description,
    @JsonKey(name: 'log_type') required DevelopmentLogType logType,
    required DevelopmentLogStatus status,
    @JsonKey(name: 'start_date') required DateTime startDate,
    @JsonKey(name: 'end_date') DateTime? endDate,
    @JsonKey(name: 'hours_spent') @Default(0.0) double hoursSpent,
    @JsonKey(name: 'related_task_id') String? relatedTaskId,
    @Default([]) List<String> attachments,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    // Additional fields for UI
    @JsonKey(includeFromJson: true, includeToJson: false) String? userName,
    @JsonKey(includeFromJson: true, includeToJson: false) String? userAvatar,
    @JsonKey(includeFromJson: true, includeToJson: false) String? taskTitle,
  }) = _DevelopmentLog;

  factory DevelopmentLog.fromJson(Map<String, dynamic> json) =>
      _$DevelopmentLogFromJson(json);
}

enum DevelopmentLogType {
  @JsonValue('feature')
  feature,
  @JsonValue('bugfix')
  bugfix,
  @JsonValue('refactor')
  refactor,
  @JsonValue('performance')
  performance,
  @JsonValue('ui')
  ui,
  @JsonValue('backend')
  backend,
  @JsonValue('other')
  other,
}

enum DevelopmentLogStatus {
  @JsonValue('in_progress')
  inProgress,
  @JsonValue('completed')
  completed,
  @JsonValue('testing')
  testing,
  @JsonValue('deployed')
  deployed,
}

extension DevelopmentLogTypeExtension on DevelopmentLogType {
  String get displayName {
    switch (this) {
      case DevelopmentLogType.feature:
        return '기능 개발';
      case DevelopmentLogType.bugfix:
        return '버그 수정';
      case DevelopmentLogType.refactor:
        return '리팩토링';
      case DevelopmentLogType.performance:
        return '성능 개선';
      case DevelopmentLogType.ui:
        return 'UI/UX';
      case DevelopmentLogType.backend:
        return '백엔드';
      case DevelopmentLogType.other:
        return '기타';
    }
  }

  String get icon {
    switch (this) {
      case DevelopmentLogType.feature:
        return '✨';
      case DevelopmentLogType.bugfix:
        return '🐛';
      case DevelopmentLogType.refactor:
        return '♻️';
      case DevelopmentLogType.performance:
        return '⚡';
      case DevelopmentLogType.ui:
        return '🎨';
      case DevelopmentLogType.backend:
        return '🔧';
      case DevelopmentLogType.other:
        return '📝';
    }
  }
}

extension DevelopmentLogStatusExtension on DevelopmentLogStatus {
  String get displayName {
    switch (this) {
      case DevelopmentLogStatus.inProgress:
        return '진행중';
      case DevelopmentLogStatus.completed:
        return '완료';
      case DevelopmentLogStatus.testing:
        return '테스트중';
      case DevelopmentLogStatus.deployed:
        return '배포됨';
    }
  }

  String get colorHex {
    switch (this) {
      case DevelopmentLogStatus.inProgress:
        return '#2196F3'; // Blue
      case DevelopmentLogStatus.completed:
        return '#4CAF50'; // Green
      case DevelopmentLogStatus.testing:
        return '#FF9800'; // Orange
      case DevelopmentLogStatus.deployed:
        return '#9C27B0'; // Purple
    }
  }
}