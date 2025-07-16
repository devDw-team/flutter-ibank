import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'project_model.freezed.dart';
part 'project_model.g.dart';

enum ProjectStatus {
  @JsonValue('planning')
  planning,
  @JsonValue('active')
  active,
  @JsonValue('on_hold')
  onHold,
  @JsonValue('completed')
  completed,
  @JsonValue('cancelled')
  cancelled,
}

enum ProjectMemberRole {
  @JsonValue('owner')
  owner,
  @JsonValue('manager')
  manager,
  @JsonValue('member')
  member,
  @JsonValue('viewer')
  viewer,
}

@freezed
class ProjectModel with _$ProjectModel {
  const factory ProjectModel({
    required String id,
    required String name,
    String? description,
    @Default(ProjectStatus.planning) ProjectStatus status,
    @JsonKey(name: 'owner_id') required String ownerId,
    @JsonKey(name: 'start_date') DateTime? startDate,
    @JsonKey(name: 'end_date') DateTime? endDate,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    // Additional fields for frontend use
    @Default([]) List<ProjectMemberModel> members,
    String? ownerName,
    String? ownerEmail,
  }) = _ProjectModel;

  factory ProjectModel.fromJson(Map<String, dynamic> json) =>
      _$ProjectModelFromJson(json);
}

@freezed
class ProjectMemberModel with _$ProjectMemberModel {
  const factory ProjectMemberModel({
    required String id,
    @JsonKey(name: 'project_id') required String projectId,
    @JsonKey(name: 'user_id') required String userId,
    @Default(ProjectMemberRole.member) ProjectMemberRole role,
    @JsonKey(name: 'joined_at') required DateTime joinedAt,
    // User details for display
    String? userName,
    String? userEmail,
    String? userAvatar,
  }) = _ProjectMemberModel;

  factory ProjectMemberModel.fromJson(Map<String, dynamic> json) =>
      _$ProjectMemberModelFromJson(json);
}

extension ProjectStatusX on ProjectStatus {
  String get displayName {
    switch (this) {
      case ProjectStatus.planning:
        return '계획중';
      case ProjectStatus.active:
        return '진행중';
      case ProjectStatus.onHold:
        return '보류';
      case ProjectStatus.completed:
        return '완료';
      case ProjectStatus.cancelled:
        return '취소';
    }
  }

  Color get color {
    switch (this) {
      case ProjectStatus.planning:
        return const Color(0xFF9E9E9E);
      case ProjectStatus.active:
        return const Color(0xFF2196F3);
      case ProjectStatus.onHold:
        return const Color(0xFFFF9800);
      case ProjectStatus.completed:
        return const Color(0xFF4CAF50);
      case ProjectStatus.cancelled:
        return const Color(0xFFF44336);
    }
  }
}

extension ProjectMemberRoleX on ProjectMemberRole {
  String get displayName {
    switch (this) {
      case ProjectMemberRole.owner:
        return '소유자';
      case ProjectMemberRole.manager:
        return '관리자';
      case ProjectMemberRole.member:
        return '구성원';
      case ProjectMemberRole.viewer:
        return '뷰어';
    }
  }

  bool get canEdit => this == ProjectMemberRole.owner || this == ProjectMemberRole.manager;
  bool get canManageMembers => this == ProjectMemberRole.owner || this == ProjectMemberRole.manager;
  bool get canDelete => this == ProjectMemberRole.owner;
}