import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/models/project_model.dart';
import '../providers/project_provider.dart';
import '../widgets/development_logs_section.dart';

class ProjectDetailScreen extends ConsumerWidget {
  final String projectId;

  const ProjectDetailScreen({
    super.key,
    required this.projectId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectAsync = ref.watch(projectDetailProvider(projectId));
    final userRole = ref.watch(userProjectRoleProvider(projectId));
    final projectActions = ref.watch(projectActionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('프로젝트 상세'),
        elevation: 0,
        actions: projectAsync.maybeWhen(
          data: (project) => userRole?.canEdit == true
              ? [
                  PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'edit') {
                        context.push('/projects/edit/$projectId');
                      } else if (value == 'delete' && userRole?.canDelete == true) {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('프로젝트 삭제'),
                            content: const Text('정말로 이 프로젝트를 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text('취소'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                style: TextButton.styleFrom(
                                  foregroundColor: Theme.of(context).colorScheme.error,
                                ),
                                child: const Text('삭제'),
                              ),
                            ],
                          ),
                        );

                        if (confirmed == true) {
                          try {
                            await projectActions.deleteProject(projectId);
                            if (context.mounted) {
                              context.go('/projects');
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('프로젝트가 삭제되었습니다.'),
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('오류: $e'),
                                  backgroundColor: Theme.of(context).colorScheme.error,
                                ),
                              );
                            }
                          }
                        }
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: Theme.of(context).colorScheme.onSurfaceVariant),
                            SizedBox(width: 8),
                            Text('수정'),
                          ],
                        ),
                      ),
                      if (userRole?.canDelete == true)
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
                              SizedBox(width: 8),
                              Text('삭제', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ]
              : null,
          orElse: () => null,
        ),
      ),
      body: projectAsync.when(
        data: (project) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Project Info Card
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Theme.of(context).dividerColor),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              project.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: project.status.color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: project.status.color.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              project.status.displayName,
                              style: TextStyle(
                                fontSize: 14,
                                color: project.status.color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (project.description != null && project.description!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          project.description!,
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      // Project Details
                      _buildInfoRow(
                        context: context,
                        icon: Icons.person,
                        label: '소유자',
                        value: project.ownerName ?? '알 수 없음',
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        context: context,
                        icon: Icons.calendar_today,
                        label: '프로젝트 기간',
                        value: _formatDateRange(project.startDate, project.endDate),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        context: context,
                        icon: Icons.update,
                        label: '마지막 업데이트',
                        value: DateFormat('yyyy.MM.dd HH:mm').format(project.updatedAt),
                      ),
                      // Progress indicator
                      if (project.status == ProjectStatus.active && 
                          project.startDate != null && 
                          project.endDate != null) ...[
                        const SizedBox(height: 20),
                        _buildProgressSection(context, project),
                      ],
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Development Logs Section
              DevelopmentLogsSection(projectId: projectId),
              
              const SizedBox(height: 20),
              
              // Members Section
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Theme.of(context).dividerColor),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '프로젝트 멤버',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (userRole?.canManageMembers == true)
                            TextButton.icon(
                              onPressed: () => _showAddMemberDialog(context, ref, project),
                              icon: const Icon(Icons.person_add, size: 20),
                              label: const Text('멤버 추가'),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (project.members.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            child: Text(
                              '프로젝트 멤버가 없습니다',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        )
                      else
                        ...project.members.map((member) => _MemberListItem(
                          member: member,
                          project: project,
                          currentUserRole: userRole,
                          onRoleChanged: userRole?.canManageMembers == true
                              ? (newRole) async {
                                  try {
                                    await projectActions.updateMemberRole(
                                      projectId: project.id,
                                      userId: member.userId,
                                      newRole: newRole,
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('멤버 권한이 변경되었습니다.'),
                                      ),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('오류: $e'),
                                        backgroundColor: Theme.of(context).colorScheme.error,
                                      ),
                                    );
                                  }
                                }
                              : null,
                          onRemove: userRole?.canManageMembers == true && 
                                    member.role != ProjectMemberRole.owner
                              ? () async {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('멤버 제거'),
                                      content: Text('${member.userName ?? '이 멤버'}를 프로젝트에서 제거하시겠습니까?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(false),
                                          child: const Text('취소'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(true),
                                          style: TextButton.styleFrom(
                                            foregroundColor: Theme.of(context).colorScheme.error,
                                          ),
                                          child: const Text('제거'),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirmed == true) {
                                    try {
                                      await projectActions.removeMember(
                                        projectId: project.id,
                                        userId: member.userId,
                                      );
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('멤버가 제거되었습니다.'),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('오류: $e'),
                                            backgroundColor: Theme.of(context).colorScheme.error,
                                          ),
                                        );
                                      }
                                    }
                                  }
                                }
                              : null,
                        )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text('오류: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(projectDetailProvider(projectId)),
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 14,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDateRange(DateTime? start, DateTime? end) {
    final format = DateFormat('yyyy.MM.dd');
    
    if (start != null && end != null) {
      return '${format.format(start)} - ${format.format(end)}';
    } else if (start != null) {
      return '${format.format(start)} ~';
    } else if (end != null) {
      return '~ ${format.format(end)}';
    }
    return '미정';
  }

  Widget _buildProgressSection(BuildContext context, ProjectModel project) {
    if (project.startDate == null || project.endDate == null) {
      return const SizedBox.shrink();
    }

    final now = DateTime.now();
    final totalDays = project.endDate!.difference(project.startDate!).inDays;
    final elapsedDays = now.difference(project.startDate!).inDays;
    final progress = (elapsedDays / totalDays).clamp(0.0, 1.0);
    final remainingDays = project.endDate!.difference(now).inDays;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '진행률',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}% (${remainingDays > 0 ? '$remainingDays일 남음' : '기한 초과'})',
              style: TextStyle(
                fontSize: 14,
                color: remainingDays > 0 ? Theme.of(context).colorScheme.onSurfaceVariant : Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Theme.of(context).colorScheme.surfaceVariant.withValues(alpha: 0.5),
          valueColor: AlwaysStoppedAnimation<Color>(
            remainingDays < 0 
                ? Theme.of(context).colorScheme.error
                : progress > 0.8 
                    ? AppColors.warning 
                    : AppColors.primary,
          ),
          minHeight: 8,
        ),
      ],
    );
  }

  Future<void> _showAddMemberDialog(
    BuildContext context,
    WidgetRef ref,
    ProjectModel project,
  ) async {
    final emailController = TextEditingController();
    ProjectMemberRole selectedRole = ProjectMemberRole.member;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('멤버 추가'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: '이메일',
                  hintText: 'member@example.com',
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              const Text('권한'),
              const SizedBox(height: 8),
              DropdownButton<ProjectMemberRole>(
                value: selectedRole,
                isExpanded: true,
                items: ProjectMemberRole.values
                    .where((role) => role != ProjectMemberRole.owner)
                    .map((role) => DropdownMenuItem(
                          value: role,
                          child: Text(role.displayName),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedRole = value;
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () async {
                final email = emailController.text.trim();
                if (email.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('이메일을 입력해주세요.'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                  return;
                }

                try {
                  final projectActions = ref.read(projectActionsProvider);
                  await projectActions.addMember(
                    projectId: project.id,
                    userEmail: email,
                    role: selectedRole,
                  );
                  
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('멤버가 추가되었습니다.'),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('오류: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('추가'),
            ),
          ],
        ),
      ),
    );

    emailController.dispose();
  }
}

class _MemberListItem extends StatelessWidget {
  final ProjectMemberModel member;
  final ProjectModel project;
  final ProjectMemberRole? currentUserRole;
  final Function(ProjectMemberRole)? onRoleChanged;
  final VoidCallback? onRemove;

  const _MemberListItem({
    required this.member,
    required this.project,
    this.currentUserRole,
    this.onRoleChanged,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Text(
              (member.userName ?? member.userEmail ?? 'U')[0].toUpperCase(),
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.userName ?? member.userEmail ?? '알 수 없음',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (member.userEmail != null)
                  Text(
                    member.userEmail!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          if (member.role == ProjectMemberRole.owner)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                member.role.displayName,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else if (onRoleChanged != null)
            PopupMenuButton<ProjectMemberRole>(
              initialValue: member.role,
              onSelected: onRoleChanged,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      member.role.displayName,
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_drop_down, size: 16),
                  ],
                ),
              ),
              itemBuilder: (context) => ProjectMemberRole.values
                  .where((role) => role != ProjectMemberRole.owner)
                  .map((role) => PopupMenuItem(
                        value: role,
                        child: Text(role.displayName),
                      ))
                  .toList(),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                member.role.displayName,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          if (onRemove != null)
            IconButton(
              icon: Icon(Icons.remove_circle_outline, color: Theme.of(context).colorScheme.error),
              onPressed: onRemove,
              iconSize: 20,
            ),
        ],
      ),
    );
  }
}