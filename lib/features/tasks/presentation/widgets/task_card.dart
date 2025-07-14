import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
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
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
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
                      color: Colors.grey[600],
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
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '담당자 지정됨',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
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
        color = Colors.red;
        text = '긴급';
        break;
      case TaskPriority.high:
        color = Colors.orange;
        text = '높음';
        break;
      case TaskPriority.medium:
        color = Colors.blue;
        text = '보통';
        break;
      case TaskPriority.low:
        color = Colors.green;
        text = '낮음';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
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
        color = Colors.grey;
        icon = Icons.schedule;
        break;
      case TaskStatus.inProgress:
        color = Colors.blue;
        icon = Icons.play_arrow;
        break;
      case TaskStatus.completed:
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case TaskStatus.cancelled:
        color = Colors.red;
        icon = Icons.cancel;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
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
      return Colors.red; // 지난 마감일
    } else if (difference <= 1) {
      return Colors.orange; // 1일 이내
    } else if (difference <= 3) {
      return Colors.amber; // 3일 이내
    } else {
      return Colors.grey; // 여유 있음
    }
  }
} 