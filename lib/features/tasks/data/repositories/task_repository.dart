import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/task_model.dart';

// Import generated enum maps
const _$TaskStatusEnumMap = {
  TaskStatus.pending: 'pending',
  TaskStatus.inProgress: 'in_progress',
  TaskStatus.completed: 'completed',
  TaskStatus.cancelled: 'cancelled',
};

const _$TaskPriorityEnumMap = {
  TaskPriority.low: 'low',
  TaskPriority.medium: 'medium',
  TaskPriority.high: 'high',
  TaskPriority.urgent: 'urgent',
};

class TaskRepository {
  final SupabaseClient _supabase;

  TaskRepository(this._supabase);

  // 모든 할일 조회
  Future<List<TaskModel>> getTasks() async {
    try {
      final response = await _supabase
          .from('tasks')
          .select('''
            *,
            assigned_to_user:users!assigned_to(id, name, avatar_url),
            assigned_by_user:users!assigned_by(id, name, avatar_url)
          ''')
          .order('created_at', ascending: false);

      return response.map((json) => TaskModel.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      throw Exception('Failed to fetch tasks: ${e.message}');
    }
  }

  // 내가 할당받은 할일 조회
  Future<List<TaskModel>> getMyTasks() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _supabase
          .from('tasks')
          .select('''
            *,
            assigned_to_user:users!assigned_to(id, name, avatar_url),
            assigned_by_user:users!assigned_by(id, name, avatar_url)
          ''')
          .or('user_id.eq.$userId,assigned_to.eq.$userId')
          .order('created_at', ascending: false);

      return response.map((json) => TaskModel.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      throw Exception('Failed to fetch my tasks: ${e.message}');
    }
  }

  // 할일 생성
  Future<TaskModel> createTask(TaskModel task) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final taskData = {
        'user_id': userId,
        'title': task.title,
        'description': task.description,
        'status': _$TaskStatusEnumMap[task.status],
        'priority': _$TaskPriorityEnumMap[task.priority],
        'due_date': task.dueDate?.toIso8601String(),
        'assigned_to': task.assignedTo,
        'assigned_by': task.assignedBy,
      };

      final response = await _supabase
          .from('tasks')
          .insert(taskData)
          .select()
          .single();

      return TaskModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw Exception('Failed to create task: ${e.message}');
    }
  }

  // 할일 수정
  Future<TaskModel> updateTask(TaskModel task) async {
    try {
      final taskData = task.toJson();
      taskData['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .from('tasks')
          .update(taskData)
          .eq('id', task.id)
          .select()
          .single();

      return TaskModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw Exception('Failed to update task: ${e.message}');
    }
  }

  // 할일 삭제
  Future<void> deleteTask(String taskId) async {
    try {
      await _supabase
          .from('tasks')
          .delete()
          .eq('id', taskId);
    } on PostgrestException catch (e) {
      throw Exception('Failed to delete task: ${e.message}');
    }
  }

  // 할일 상태 변경
  Future<TaskModel> updateTaskStatus(String taskId, TaskStatus status) async {
    try {
      final updateData = <String, dynamic>{
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // 완료 상태로 변경할 때 완료 시간 기록
      if (status == TaskStatus.completed) {
        updateData['completed_at'] = DateTime.now().toIso8601String();
      } else {
        updateData['completed_at'] = null;
      }

      final response = await _supabase
          .from('tasks')
          .update(updateData)
          .eq('id', taskId)
          .select()
          .single();

      return TaskModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw Exception('Failed to update task status: ${e.message}');
    }
  }

  // 실시간 할일 변경사항 구독
  Stream<List<TaskModel>> watchTasks() {
    return _supabase
        .from('tasks')
        .stream(primaryKey: ['id'])
        .map((data) => data.map((json) => TaskModel.fromJson(json)).toList());
  }
} 