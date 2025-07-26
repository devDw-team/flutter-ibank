import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../data/models/development_log.dart';
import '../providers/development_log_provider.dart';
import '../../../tasks/presentation/providers/task_provider.dart';

class DevelopmentLogFormScreen extends ConsumerStatefulWidget {
  final String projectId;
  final String? logId;

  const DevelopmentLogFormScreen({
    super.key,
    required this.projectId,
    this.logId,
  });

  @override
  ConsumerState<DevelopmentLogFormScreen> createState() => _DevelopmentLogFormScreenState();
}

class _DevelopmentLogFormScreenState extends ConsumerState<DevelopmentLogFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _hoursSpentController = TextEditingController();
  
  late DevelopmentLogType _selectedType;
  late DevelopmentLogStatus _selectedStatus;
  late DateTime _startDate;
  DateTime? _endDate;
  String? _selectedTaskId;
  
  bool _isLoading = false;
  DevelopmentLog? _existingLog;

  @override
  void initState() {
    super.initState();
    print('DevelopmentLogFormScreen initState - projectId: ${widget.projectId}, logId: ${widget.logId}');
    _selectedType = DevelopmentLogType.feature;
    _selectedStatus = DevelopmentLogStatus.inProgress;
    _startDate = DateTime.now();
    _hoursSpentController.text = '0';
    
    if (widget.logId != null) {
      _loadExistingLog();
    }
  }

  Future<void> _loadExistingLog() async {
    try {
      final logsState = ref.read(developmentLogsProvider(widget.projectId));
      final log = logsState.logs.cast<DevelopmentLog?>().firstWhere(
        (log) => log?.id == widget.logId,
        orElse: () => null,
      );
      
      if (log != null) {
        _existingLog = log;
        setState(() {
          _titleController.text = log.title;
          _descriptionController.text = log.description ?? '';
          _hoursSpentController.text = log.hoursSpent.toString();
          _selectedType = log.logType;
          _selectedStatus = log.status;
          _startDate = log.startDate;
          _endDate = log.endDate;
          _selectedTaskId = log.relatedTaskId;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('개발 이력을 불러올 수 없습니다'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _hoursSpentController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : (_endDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final logsNotifier = ref.read(developmentLogsProvider(widget.projectId).notifier);
      final hoursSpent = double.tryParse(
        _hoursSpentController.text.isEmpty ? '0' : _hoursSpentController.text,
      ) ?? 0.0;

      if (widget.logId != null) {
        // Update existing log
        await logsNotifier.updateDevelopmentLog(
          logId: widget.logId!,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          logType: _selectedType,
          status: _selectedStatus,
          startDate: _startDate,
          endDate: _endDate,
          hoursSpent: hoursSpent,
          relatedTaskId: _selectedTaskId,
        );
      } else {
        // Create new log
        await logsNotifier.createDevelopmentLog(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          logType: _selectedType,
          status: _selectedStatus,
          startDate: _startDate,
          endDate: _endDate,
          hoursSpent: hoursSpent,
          relatedTaskId: _selectedTaskId,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.logId != null ? '개발 이력이 수정되었습니다' : '개발 이력이 추가되었습니다'),
          ),
        );
        context.pop();
      }
    } catch (e, stack) {
      print('_submitForm error: $e');
      print('Stack trace: $stack');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('오류가 발생했습니다'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    print('DevelopmentLogFormScreen build - projectId: ${widget.projectId}');
    final tasksAsync = ref.watch(tasksProvider(widget.projectId));
    print('DevelopmentLogFormScreen build - tasksAsync: $tasksAsync');

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.logId != null ? '개발이력 수정' : '개발이력 추가'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '제목',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '제목을 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Type and Status
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<DevelopmentLogType>(
                      value: _selectedType,
                      decoration: const InputDecoration(
                        labelText: '유형',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: DevelopmentLogType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Row(
                            children: [
                              Text(type.icon),
                              const SizedBox(width: 8),
                              Text(type.displayName),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedType = value);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<DevelopmentLogStatus>(
                      value: _selectedStatus,
                      decoration: const InputDecoration(
                        labelText: '상태',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.flag),
                      ),
                      items: DevelopmentLogStatus.values.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Color(int.parse(
                                    status.colorHex.replaceFirst('#', '0xFF'),
                                  )),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(status.displayName),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedStatus = value);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Start and End Date
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context, true),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: '시작일',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          DateFormat('yyyy-MM-dd').format(_startDate),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context, false),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: '종료일',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          _endDate != null
                              ? DateFormat('yyyy-MM-dd').format(_endDate!)
                              : '선택 안함',
                          style: TextStyle(
                            color: _endDate != null
                                ? null
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Hours Spent and Related Task
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _hoursSpentController,
                      decoration: const InputDecoration(
                        labelText: '투입 시간',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.access_time),
                        suffixText: '시간',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final hours = double.tryParse(value);
                          if (hours == null || hours < 0) {
                            return '올바른 시간을 입력해주세요';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: tasksAsync.when(
                      data: (tasks) {
                        return DropdownButtonFormField<String?>(
                          value: _selectedTaskId,
                          decoration: const InputDecoration(
                            labelText: '관련 작업',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.task_alt),
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('선택 안함'),
                            ),
                            ...tasks.map((task) {
                              return DropdownMenuItem(
                                value: task.id,
                                child: Text(
                                  task.title,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }),
                          ],
                          onChanged: (value) {
                            setState(() => _selectedTaskId = value);
                          },
                        );
                      },
                      loading: () => const SizedBox(
                        height: 56,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (error, stack) => Container(
                        height: 56,
                        decoration: BoxDecoration(
                          border: Border.all(color: theme.colorScheme.outline),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Center(
                          child: Text('작업 목록을 불러올 수 없습니다'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: '설명',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 72),
                    child: Icon(Icons.description),
                  ),
                ),
                maxLines: 4,
              ),
              
              const SizedBox(height: 32),
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: _isLoading ? null : _submitForm,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : Text(widget.logId != null ? '수정하기' : '추가하기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}