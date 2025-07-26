import 'package:freezed_annotation/freezed_annotation.dart';

part 'task_model.freezed.dart';
part 'task_model.g.dart';

enum TaskStatus { 
  @JsonValue('pending') pending, 
  @JsonValue('in_progress') inProgress, 
  @JsonValue('completed') completed, 
  @JsonValue('cancelled') cancelled 
}

enum TaskPriority { 
  @JsonValue('low') low, 
  @JsonValue('medium') medium, 
  @JsonValue('high') high, 
  @JsonValue('urgent') urgent 
}

@freezed
class TaskModel with _$TaskModel {
  const factory TaskModel({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'project_id') String? projectId,
    required String title,
    String? description,
    @Default(TaskStatus.pending) TaskStatus status,
    @Default(TaskPriority.medium) TaskPriority priority,
    @JsonKey(name: 'due_date') DateTime? dueDate,
    @JsonKey(name: 'assigned_to') String? assignedTo,
    @JsonKey(name: 'assigned_by') String? assignedBy,
    @JsonKey(name: 'completed_at') DateTime? completedAt,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _TaskModel;

  factory TaskModel.fromJson(Map<String, dynamic> json) =>
      _$TaskModelFromJson(json);
} 