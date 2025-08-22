import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/models/task_model.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onTap;
  final Function(TaskStatus)? onStatusChanged;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        elevation: 2,
        shadowColor: Theme.of(context).shadowColor.withValues(alpha: 0.1),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 제목과 우선순위
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildPriorityChip(task.priority),
                  ],
                ),
                
                // 설명
                if (task.description != null && task.description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    task.description!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                
                const SizedBox(height: 12),
                
                // 마감일과 상태
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 마감일
                    if (task.dueDate != null)
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 16,
                            color: _getDueDateColor(task.dueDate!),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('MM/dd').format(task.dueDate!),
                            style: TextStyle(
                              fontSize: 12,
                              color: _getDueDateColor(task.dueDate!),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      )
                    else
                      const SizedBox.shrink(),
                    
                    // 상태 표시
                    _buildStatusIndicator(task.status),
                  ],
                ),
                
                // 할당자 정보
                if (task.assignedTo != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '담당자 지정됨',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityChip(TaskPriority priority) {
    Color color;
    String text;
    
    switch (priority) {
      case TaskPriority.urgent:
        color = AppColors.error;
        text = '긴급';
        break;
      case TaskPriority.high:
        color = AppColors.warning;
        text = '높음';
        break;
      case TaskPriority.medium:
        color = AppColors.primary;
        text = '보통';
        break;
      case TaskPriority.low:
        color = AppColors.success;
        text = '낮음';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(TaskStatus status) {
    Color color;
    IconData icon;
    
    switch (status) {
      case TaskStatus.pending:
        color = AppColors.textSecondary;
        icon = Icons.schedule;
        break;
      case TaskStatus.inProgress:
        color = AppColors.primary;
        icon = Icons.play_arrow;
        break;
      case TaskStatus.review:
        color = Colors.deepPurple;
        icon = Icons.fact_check;
        break;
      case TaskStatus.completed:
        color = AppColors.success;
        icon = Icons.check_circle;
        break;
      case TaskStatus.onHold:
        color = AppColors.warning;
        icon = Icons.pause_circle;
        break;
      case TaskStatus.cancelled:
        color = AppColors.error;
        icon = Icons.cancel;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 16,
        color: color,
      ),
    );
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