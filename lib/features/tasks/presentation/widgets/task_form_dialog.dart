import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/task_model.dart';
import '../../../../features/auth/data/models/user_model.dart';
import '../../../../shared/providers/supabase_provider.dart';

class TaskFormDialog extends ConsumerStatefulWidget {
  final TaskModel? task;
  final Function(TaskModel) onSave;
  final VoidCallback? onDelete;

  const TaskFormDialog({
    super.key,
    this.task,
    required this.onSave,
    this.onDelete,
  });

  @override
  ConsumerState<TaskFormDialog> createState() => _TaskFormDialogState();
}

class _TaskFormDialogState extends ConsumerState<TaskFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  TaskStatus _status = TaskStatus.pending;
  TaskPriority _priority = TaskPriority.medium;
  DateTime? _dueDate;
  String? _assignedTo;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description ?? '';
      _status = widget.task!.status;
      _priority = widget.task!.priority;
      _dueDate = widget.task!.dueDate;
      _assignedTo = widget.task!.assignedTo;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.task == null ? '새 할일 추가' : '할일 수정'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 제목
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '제목 *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '제목을 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // 설명
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: '설명',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              
              // 상태
              DropdownButtonFormField<TaskStatus>(
                value: _status,
                decoration: const InputDecoration(
                  labelText: '상태',
                  border: OutlineInputBorder(),
                ),
                items: TaskStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(_getStatusText(status)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _status = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // 우선순위
              DropdownButtonFormField<TaskPriority>(
                value: _priority,
                decoration: const InputDecoration(
                  labelText: '우선순위',
                  border: OutlineInputBorder(),
                ),
                items: TaskPriority.values.map((priority) {
                  return DropdownMenuItem(
                    value: priority,
                    child: Text(_getPriorityText(priority)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _priority = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // 마감일
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _dueDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() {
                      _dueDate = date;
                    });
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: '마감일',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _dueDate != null 
                        ? DateFormat('yyyy-MM-dd').format(_dueDate!)
                        : '마감일을 선택하세요',
                    style: TextStyle(
                      color: _dueDate != null ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              
              // 마감일 제거 버튼
              if (_dueDate != null) ...[
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _dueDate = null;
                    });
                  },
                  child: const Text('마감일 제거'),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        // 삭제 버튼 (수정 시에만)
        if (widget.task != null && widget.onDelete != null)
          TextButton(
            onPressed: _isLoading ? null : () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('할일 삭제'),
                  content: const Text('정말로 이 할일을 삭제하시겠습니까?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('취소'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        widget.onDelete!();
                      },
                      child: const Text('삭제', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        
        // 취소 버튼
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        
        // 저장 버튼
        ElevatedButton(
          onPressed: _isLoading ? null : _saveTask,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.task == null ? '추가' : '수정'),
        ),
      ],
    );
  }

  void _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = ref.read(currentUserProvider);
      if (currentUser == null) {
        throw Exception('사용자 인증이 필요합니다');
      }

      final now = DateTime.now();
      final task = TaskModel(
        id: widget.task?.id ?? const Uuid().v4(),
        userId: currentUser.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        status: _status,
        priority: _priority,
        dueDate: _dueDate,
        assignedTo: _assignedTo,
        assignedBy: widget.task?.assignedBy,
        completedAt: _status == TaskStatus.completed ? now : null,
        createdAt: widget.task?.createdAt ?? now,
        updatedAt: now,
      );

      widget.onSave(task);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getStatusText(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return '대기';
      case TaskStatus.inProgress:
        return '진행중';
      case TaskStatus.completed:
        return '완료';
      case TaskStatus.onHold:
        return '보류';
      case TaskStatus.cancelled:
        return '취소';
    }
  }

  String _getPriorityText(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return '낮음';
      case TaskPriority.medium:
        return '보통';
      case TaskPriority.high:
        return '높음';
      case TaskPriority.urgent:
        return '긴급';
    }
  }
} 