import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/task_model.dart';
import '../../data/repositories/task_repository.dart';
import '../../../../shared/providers/supabase_provider.dart';

// Task Repository Provider
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return TaskRepository(supabase);
});

// All Tasks Provider
final allTasksProvider = FutureProvider<List<TaskModel>>((ref) async {
  final repository = ref.watch(taskRepositoryProvider);
  return repository.getTasks();
});

// My Tasks Provider
final myTasksProvider = FutureProvider<List<TaskModel>>((ref) async {
  final repository = ref.watch(taskRepositoryProvider);
  return repository.getMyTasks();
});

// Grouped Tasks Provider (for Kanban board)
final groupedTasksProvider = Provider<Map<TaskStatus, List<TaskModel>>>((ref) {
  final tasksAsync = ref.watch(myTasksProvider);
  
  return tasksAsync.when(
    data: (tasks) {
      final Map<TaskStatus, List<TaskModel>> groupedTasks = {
        TaskStatus.pending: [],
        TaskStatus.inProgress: [],
        TaskStatus.review: [],
        TaskStatus.completed: [],
        TaskStatus.onHold: [],
        TaskStatus.cancelled: [],
      };
      
      for (final task in tasks) {
        groupedTasks[task.status]?.add(task);
      }
      
      // 각 상태별로 우선순위 순서로 정렬 (긴급 > 높음 > 보통 > 낮음)
      final priorityOrder = {
        TaskPriority.urgent: 0,
        TaskPriority.high: 1,
        TaskPriority.medium: 2,
        TaskPriority.low: 3,
      };
      
      groupedTasks.forEach((status, taskList) {
        taskList.sort((a, b) {
          final priorityA = priorityOrder[a.priority] ?? 999;
          final priorityB = priorityOrder[b.priority] ?? 999;
          if (priorityA != priorityB) {
            return priorityA.compareTo(priorityB);
          }
          // 같은 우선순위인 경우 생성일 기준 최신순
          return b.createdAt.compareTo(a.createdAt);
        });
      });
      
      return groupedTasks;
    },
    loading: () => {
      TaskStatus.pending: [],
      TaskStatus.inProgress: [],
      TaskStatus.review: [],
      TaskStatus.completed: [],
      TaskStatus.onHold: [],
      TaskStatus.cancelled: [],
    },
    error: (_, __) => {
      TaskStatus.pending: [],
      TaskStatus.inProgress: [],
      TaskStatus.review: [],
      TaskStatus.completed: [],
      TaskStatus.onHold: [],
      TaskStatus.cancelled: [],
    },
  );
});

// Tasks by Project Provider
final tasksProvider = FutureProvider.family<List<TaskModel>, String>((ref, projectId) async {
  print('tasksProvider called with projectId: $projectId');
  
  if (projectId.isEmpty) {
    print('tasksProvider: projectId is empty, returning empty list');
    return [];
  }
  
  try {
    final repository = ref.watch(taskRepositoryProvider);
    final tasks = await repository.getTasksByProject(projectId);
    print('tasksProvider success - found ${tasks.length} tasks');
    return tasks;
  } catch (e, stack) {
    print('tasksProvider error: $e');
    print('Stack trace: $stack');
    rethrow;
  }
});

// Task Actions Provider
final taskActionsProvider = Provider<TaskActions>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return TaskActions(repository, ref);
});

class TaskActions {
  final TaskRepository _repository;
  final Ref _ref;
  
  TaskActions(this._repository, this._ref);
  
  // 할일 생성
  Future<void> createTask(TaskModel task) async {
    try {
      await _repository.createTask(task);
      _ref.invalidate(myTasksProvider);
      _ref.invalidate(allTasksProvider);
    } catch (e) {
      rethrow;
    }
  }
  
  // 할일 수정
  Future<void> updateTask(TaskModel task) async {
    try {
      await _repository.updateTask(task);
      _ref.invalidate(myTasksProvider);
      _ref.invalidate(allTasksProvider);
    } catch (e) {
      rethrow;
    }
  }
  
  // 할일 삭제
  Future<void> deleteTask(String taskId) async {
    try {
      await _repository.deleteTask(taskId);
      _ref.invalidate(myTasksProvider);
      _ref.invalidate(allTasksProvider);
      // 프로젝트별 tasks provider도 invalidate
      _ref.invalidate(tasksProvider);
    } catch (e) {
      rethrow;
    }
  }
  
  // 할일 상태 변경
  Future<void> updateTaskStatus(String taskId, TaskStatus status) async {
    try {
      await _repository.updateTaskStatus(taskId, status);
      _ref.invalidate(myTasksProvider);
      _ref.invalidate(allTasksProvider);
    } catch (e) {
      rethrow;
    }
  }
} 