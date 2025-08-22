import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/providers/supabase_provider.dart';
import '../../../tasks/presentation/providers/task_provider.dart';
import '../../../tasks/data/models/task_model.dart';
import '../../../calendar/presentation/providers/calendar_provider.dart';
import '../../../calendar/data/models/event_model.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('대시보드'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Navigate to notifications
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              if (value == 'logout') {
                // Show confirmation dialog
                final shouldLogout = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('로그아웃'),
                    content: const Text('정말 로그아웃 하시겠습니까?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('취소'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('로그아웃'),
                      ),
                    ],
                  ),
                );

                if (shouldLogout == true) {
                  final supabase = ref.read(supabaseClientProvider);
                  await supabase.auth.signOut();
                  if (context.mounted) {
                    context.go('/login');
                  }
                }
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Theme.of(context).colorScheme.error),
                    const SizedBox(width: 8),
                    Text('로그아웃', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // TODO: Refresh dashboard data
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildQuickActions(context),
              const SizedBox(height: 24),
              _buildTodaysSummary(context, ref),
              const SizedBox(height: 24),
              _buildRecentTasks(context, ref),
              const SizedBox(height: 24),
              _buildAnnouncements(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '빠른 작업',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _QuickActionButton(
                  icon: Icons.login,
                  label: AppStrings.checkIn,
                  color: AppColors.success,
                  onTap: () => context.go('/attendance'),
                ),
                _QuickActionButton(
                  icon: Icons.logout,
                  label: AppStrings.checkOut,
                  color: AppColors.warning,
                  onTap: () => context.go('/attendance'),
                ),
                _QuickActionButton(
                  icon: Icons.add_task,
                  label: '할 일 추가',
                  color: AppColors.primary,
                  onTap: () => context.push('/tasks/add'),
                ),
                _QuickActionButton(
                  icon: Icons.event,
                  label: '일정 추가',
                  color: Theme.of(context).colorScheme.secondary,
                  onTap: () => context.push('/calendar/add'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaysSummary(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(myTasksProvider);
    final eventsAsync = ref.watch(dayEventsProvider);
    
    // 오늘 완료한 작업 수 계산
    final completedTasksToday = tasksAsync.when(
      data: (tasks) => tasks.where((task) {
        if (task.status != TaskStatus.completed) return false;
        final today = DateTime.now();
        return task.updatedAt.year == today.year &&
               task.updatedAt.month == today.month &&
               task.updatedAt.day == today.day;
      }).length,
      loading: () => 0,
      error: (_, __) => 0,
    );
    
    // 오늘 예정된 일정 수
    final todayEventsCount = eventsAsync.when(
      data: (events) => events.length,
      loading: () => 0,
      error: (_, __) => 0,
    );
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '오늘의 요약',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _SummaryItem(
              icon: Icons.access_time,
              label: '근무시간',
              value: '0시간 0분',
              color: AppColors.primary,
            ),
            const SizedBox(height: 8),
            _SummaryItem(
              icon: Icons.task_alt,
              label: '완료한 작업',
              value: '$completedTasksToday개',
              color: AppColors.success,
            ),
            const SizedBox(height: 8),
            _SummaryItem(
              icon: Icons.event,
              label: '예정된 일정',
              value: '$todayEventsCount개',
              color: Theme.of(context).colorScheme.secondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTasks(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(myTasksProvider);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '최근 할 일',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => context.go('/tasks'),
                  child: const Text('모두 보기'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            tasksAsync.when(
              data: (tasks) {
                // 진행중이거나 대기중인 작업만 표시 (최근 5개)
                final recentTasks = tasks
                    .where((task) => 
                      task.status == TaskStatus.pending || 
                      task.status == TaskStatus.inProgress
                    )
                    .take(5)
                    .toList();
                
                if (recentTasks.isEmpty) {
                  return Center(
                    child: Text(
                      '진행 중인 할일이 없습니다',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                }
                
                return Column(
                  children: recentTasks.map((task) => 
                    _TaskListItem(
                      task: task,
                      onTap: () => context.push('/tasks/detail/${task.id}'),
                    ),
                  ).toList(),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, _) => Center(
                child: Text(
                  '오류가 발생했습니다',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncements(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '공지사항',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                '새로운 공지사항이 없습니다',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SummaryItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _TaskListItem extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onTap;

  const _TaskListItem({
    required this.task,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: _getPriorityColor(task.priority),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (task.dueDate != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: _getDueDateColor(task.dueDate!),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('MM/dd').format(task.dueDate!),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: _getDueDateColor(task.dueDate!),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Chip(
              label: Text(
                _getStatusText(task.status),
                style: const TextStyle(fontSize: 12),
              ),
              backgroundColor: _getStatusColor(task.status).withOpacity(0.2),
              side: BorderSide.none,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.urgent:
        return AppColors.error;
      case TaskPriority.high:
        return AppColors.warning;
      case TaskPriority.medium:
        return AppColors.primary;
      case TaskPriority.low:
        return AppColors.success;
    }
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return AppColors.textSecondary;
      case TaskStatus.inProgress:
        return AppColors.primary;
      case TaskStatus.review:
        return Colors.deepPurple;
      case TaskStatus.completed:
        return AppColors.success;
      case TaskStatus.onHold:
        return AppColors.warning;
      case TaskStatus.cancelled:
        return AppColors.error;
    }
  }

  String _getStatusText(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return '대기';
      case TaskStatus.inProgress:
        return '진행중';
      case TaskStatus.review:
        return '검수';
      case TaskStatus.completed:
        return '완료';
      case TaskStatus.onHold:
        return '보류';
      case TaskStatus.cancelled:
        return '취소';
    }
  }

  Color _getDueDateColor(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;
    
    if (difference < 0) {
      return AppColors.error; // 지난 마감일
    } else if (difference <= 1) {
      return AppColors.warning; // 1일 이내
    } else if (difference <= 3) {
      return AppColors.warning; // 3일 이내
    } else {
      return AppColors.textSecondary; // 여유 있음
    }
  }
} 