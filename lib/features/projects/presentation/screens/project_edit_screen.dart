import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../auth/data/models/user_model.dart';
import '../../data/models/project_model.dart';
import '../providers/project_provider.dart';
import '../widgets/member_selection_dialog.dart';

class ProjectEditScreen extends ConsumerStatefulWidget {
  final String projectId;

  const ProjectEditScreen({
    super.key,
    required this.projectId,
  });

  @override
  ConsumerState<ProjectEditScreen> createState() => _ProjectEditScreenState();
}

class _ProjectEditScreenState extends ConsumerState<ProjectEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  ProjectStatus _selectedStatus = ProjectStatus.planning;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;
  ProjectModel? _project;
  
  // Selected members with their roles
  final Map<UserModel, ProjectMemberRole> _selectedMembers = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProject();
    });
  }

  Future<void> _loadProject() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final projectAsync = ref.read(projectDetailProvider(widget.projectId));
      
      projectAsync.when(
        data: (project) {
          setState(() {
            _project = project;
            _nameController.text = project.name;
            _descriptionController.text = project.description ?? '';
            _selectedStatus = project.status;
            _startDate = project.startDate;
            _endDate = project.endDate;
            
            // Load existing members
            for (final member in project.members) {
              if (member.userName != null && member.userEmail != null) {
                final user = UserModel(
                  id: member.userId,
                  email: member.userEmail!,
                  name: member.userName,
                  avatarUrl: member.userAvatar,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );
                _selectedMembers[user] = member.role;
              }
            }
          });
        },
        loading: () {},
        error: (error, stack) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('프로젝트를 불러올 수 없습니다: $error'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
            context.pop();
          }
        },
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate 
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? _startDate ?? DateTime.now()),
      firstDate: isStartDate 
          ? DateTime.now().subtract(const Duration(days: 365))
          : (_startDate ?? DateTime.now()),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      locale: const Locale('ko', 'KR'),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          // If end date is before start date, clear it
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Color _getRoleColor(BuildContext context, ProjectMemberRole role) {
    switch (role) {
      case ProjectMemberRole.owner:
        return Theme.of(context).colorScheme.secondary;
      case ProjectMemberRole.manager:
        return AppColors.primary;
      case ProjectMemberRole.member:
        return AppColors.success;
      case ProjectMemberRole.viewer:
        return AppColors.warning;
    }
  }

  Future<void> _showMemberSelectionDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => MemberSelectionDialog(
        selectedMembers: _selectedMembers,
        onMembersSelected: (newMembers) {
          setState(() {
            _selectedMembers.addAll(newMembers);
          });
        },
      ),
    );
  }

  Future<void> _updateProject() async {
    if (!_formKey.currentState!.validate()) return;
    if (_project == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final projectActions = ref.read(projectActionsProvider);

      final updatedProject = _project!.copyWith(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        status: _selectedStatus,
        startDate: _startDate,
        endDate: _endDate,
        updatedAt: DateTime.now(),
      );

      await projectActions.updateProject(updatedProject);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('프로젝트가 수정되었습니다.'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류가 발생했습니다: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
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

  @override
  Widget build(BuildContext context) {
    if (_project == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('프로젝트 수정'),
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('프로젝트 수정'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name Section
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.folder, color: AppColors.primary, size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              '프로젝트명',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              ' *',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            hintText: '프로젝트 이름을 입력하세요',
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surfaceVariant.withValues(alpha: 0.5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return '프로젝트명을 입력해주세요';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Description Section
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.description, color: AppColors.primary, size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              '프로젝트 설명',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: '프로젝트에 대한 설명을 입력하세요',
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surfaceVariant.withValues(alpha: 0.5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.all(16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Status Section
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.flag, color: AppColors.primary, size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              '프로젝트 상태',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceVariant.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            childAspectRatio: 3,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                            padding: const EdgeInsets.all(8),
                            children: ProjectStatus.values.map((status) {
                              final isSelected = _selectedStatus == status;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedStatus = status;
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isSelected 
                                        ? status.color
                                        : Theme.of(context).colorScheme.surface,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isSelected 
                                          ? status.color
                                          : Theme.of(context).dividerColor,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    status.displayName,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Date Section
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.calendar_today, color: AppColors.primary, size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              '프로젝트 기간',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => _selectDate(context, true),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.surfaceVariant.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_month,
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _startDate != null
                                            ? DateFormat('yyyy.MM.dd').format(_startDate!)
                                            : '시작일',
                                        style: TextStyle(
                                          color: _startDate != null 
                                              ? Theme.of(context).colorScheme.onSurface 
                                              : Theme.of(context).colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text('~'),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () => _selectDate(context, false),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.surfaceVariant.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_month,
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _endDate != null
                                            ? DateFormat('yyyy.MM.dd').format(_endDate!)
                                            : '종료일',
                                        style: TextStyle(
                                          color: _endDate != null 
                                              ? Theme.of(context).colorScheme.onSurface 
                                              : Theme.of(context).colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : () {
                          context.pop();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('취소'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: FilledButton(
                        onPressed: _isLoading ? null : _updateProject,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('수정'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}