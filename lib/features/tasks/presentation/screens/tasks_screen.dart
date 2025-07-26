import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/models/task_model.dart';
import '../providers/task_provider.dart';
import '../widgets/task_card.dart';
import '../widgets/kanban_column.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupedTasks = ref.watch(groupedTasksProvider);
    final taskActions = ref.watch(taskActionsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('할 일 관리'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(myTasksProvider);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: _buildKanbanBoard(context, ref, groupedTasks, taskActions),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/tasks/add');
        },
        label: const Text('새 할일'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildKanbanBoard(
    BuildContext context,
    WidgetRef ref,
    Map<TaskStatus, List<TaskModel>> groupedTasks,
    TaskActions taskActions,
  ) {
    // 컬럼 설정
    final columns = [
      KanbanColumnConfig(
        status: TaskStatus.pending,
        title: '대기',
        color: AppColors.textSecondary,
        icon: Icons.schedule,
      ),
      KanbanColumnConfig(
        status: TaskStatus.inProgress,
        title: '진행중',
        color: AppColors.primary,
        icon: Icons.play_arrow,
      ),
      KanbanColumnConfig(
        status: TaskStatus.completed,
        title: '완료',
        color: AppColors.success,
        icon: Icons.check_circle,
      ),
      KanbanColumnConfig(
        status: TaskStatus.cancelled,
        title: '취소',
        color: AppColors.error,
        icon: Icons.cancel,
      ),
    ];

    // DragAndDropLists 용 리스트 생성
    final dragAndDropLists = columns.map((column) {
      final tasks = groupedTasks[column.status] ?? [];
      
      return DragAndDropList(
        header: KanbanColumnHeader(
          config: column,
          taskCount: tasks.length,
        ),
        children: tasks.isEmpty 
          ? [
              DragAndDropItem(
                child: Container(
                  height: 200,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getEmptyIcon(column.status),
                        size: 48,
                        color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _getEmptyMessage(column.status),
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getEmptySubMessage(column.status),
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                canDrag: false,
              ),
            ]
          : tasks.map((task) {
              return DragAndDropItem(
                child: TaskCard(
                  task: task,
                  onTap: () => context.push('/tasks/detail/${task.id}'),
                  onStatusChanged: (newStatus) async {
                    await taskActions.updateTaskStatus(task.id, newStatus);
                  },
                ),
              );
            }).toList(),
      );
    }).toList();

    return DragAndDropLists(
      children: dragAndDropLists,
      onItemReorder: (oldItemIndex, oldListIndex, newItemIndex, newListIndex) {
        _onItemReorder(
          context,
          ref,
          groupedTasks,
          taskActions,
          oldItemIndex,
          oldListIndex,
          newItemIndex,
          newListIndex,
          columns,
        );
      },
      onListReorder: (oldListIndex, newListIndex) {
        // 컬럼 순서 변경은 허용하지 않음
      },
      axis: Axis.horizontal,
      listWidth: MediaQuery.of(context).size.width * 0.8,
      listDragHandle: null,
      listPadding: const EdgeInsets.all(8.0),
      itemDragHandle: null,
      itemDivider: Divider(height: 1, color: Theme.of(context).dividerColor),
      itemDecorationWhileDragging: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      listInnerDecoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  void _onItemReorder(
    BuildContext context,
    WidgetRef ref,
    Map<TaskStatus, List<TaskModel>> groupedTasks,
    TaskActions taskActions,
    int oldItemIndex,
    int oldListIndex,
    int newItemIndex,
    int newListIndex,
    List<KanbanColumnConfig> columns,
  ) {
    // 같은 컬럼 내에서의 이동은 순서 변경만
    if (oldListIndex == newListIndex) {
      return;
    }

    // 다른 컬럼으로 이동하는 경우 상태 변경
    final oldStatus = columns[oldListIndex].status;
    final newStatus = columns[newListIndex].status;
    
    final tasks = groupedTasks[oldStatus] ?? [];
    if (oldItemIndex < tasks.length) {
      final task = tasks[oldItemIndex];
      taskActions.updateTaskStatus(task.id, newStatus);
    }
  }


  IconData _getEmptyIcon(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return Icons.inbox_outlined;
      case TaskStatus.inProgress:
        return Icons.engineering_outlined;
      case TaskStatus.completed:
        return Icons.celebration_outlined;
      case TaskStatus.cancelled:
        return Icons.block_outlined;
    }
  }

  String _getEmptyMessage(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return '대기 중인 할일이 없습니다';
      case TaskStatus.inProgress:
        return '진행 중인 할일이 없습니다';
      case TaskStatus.completed:
        return '완료된 할일이 없습니다';
      case TaskStatus.cancelled:
        return '취소된 할일이 없습니다';
    }
  }

  String _getEmptySubMessage(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return '새로운 할일을 추가해보세요';
      case TaskStatus.inProgress:
        return '대기 중인 할일을 시작해보세요';
      case TaskStatus.completed:
        return '훌륭해요! 계속 화이팅!';
      case TaskStatus.cancelled:
        return '취소된 작업이 여기 표시됩니다';
    }
  }
}

// Kanban 컬럼 설정 클래스
class KanbanColumnConfig {
  final TaskStatus status;
  final String title;
  final Color color;
  final IconData icon;

  KanbanColumnConfig({
    required this.status,
    required this.title,
    required this.color,
    required this.icon,
  });
} 