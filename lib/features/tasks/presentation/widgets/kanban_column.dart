import 'package:flutter/material.dart';

import '../screens/tasks_screen.dart';

class KanbanColumnHeader extends StatelessWidget {
  final KanbanColumnConfig config;
  final int taskCount;

  const KanbanColumnHeader({
    super.key,
    required this.config,
    required this.taskCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 아이콘
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: config.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              config.icon,
              size: 20,
              color: config.color,
            ),
          ),
          const SizedBox(width: 12),
          
          // 제목과 카운트
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  config.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$taskCount개의 할일',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          // 카운트 뱃지
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: config.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: config.color.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              '$taskCount',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: config.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 