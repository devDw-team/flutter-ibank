import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../data/models/development_log.dart';
import '../providers/development_log_provider.dart';

class DevelopmentLogsSection extends ConsumerWidget {
  final String projectId;

  const DevelopmentLogsSection({
    super.key,
    required this.projectId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final logsState = ref.watch(developmentLogsProvider(projectId));
    final logsNotifier = ref.read(developmentLogsProvider(projectId).notifier);
    final statsAsync = ref.watch(developmentLogStatsProvider(projectId));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.code,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  '개발 이력',
                  style: theme.textTheme.titleLarge,
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: () {
                    print('Development log add button clicked - projectId: $projectId');
                    print('Navigating to: /projects/$projectId/development-log/add');
                    context.push('/projects/$projectId/development-log/add');
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('이력 추가'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Statistics
            statsAsync.when(
              data: (stats) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        context,
                        '전체 이력',
                        stats['totalLogs'].toString(),
                        Icons.history,
                      ),
                      _buildStatItem(
                        context,
                        '총 투입시간',
                        '${stats['totalHours'].toStringAsFixed(1)}h',
                        Icons.access_time,
                      ),
                      _buildStatItem(
                        context,
                        '완료',
                        (stats['statusCounts']['completed'] ?? 0).toString(),
                        Icons.check_circle,
                      ),
                      _buildStatItem(
                        context,
                        '진행중',
                        (stats['statusCounts']['in_progress'] ?? 0).toString(),
                        Icons.pending,
                      ),
                    ],
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 24),

            // Logs List
            if (logsState.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (logsState.error != null)
              Center(
                child: Column(
                  children: [
                    Text(
                      logsState.error!,
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: logsNotifier.loadDevelopmentLogs,
                      child: const Text('다시 시도'),
                    ),
                  ],
                ),
              )
            else if (logsState.logs.isEmpty)
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.code_off,
                      size: 48,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '개발 이력이 없습니다',
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: logsState.logs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final log = logsState.logs[index];
                  return _DevelopmentLogCard(
                    log: log,
                    projectId: projectId,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(
          icon,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _DevelopmentLogCard extends ConsumerWidget {
  final DevelopmentLog log;
  final String projectId;

  const _DevelopmentLogCard({
    required this.log,
    required this.projectId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final logsNotifier = ref.read(developmentLogsProvider(projectId).notifier);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant,
        ),
      ),
      child: InkWell(
        onTap: () {
          context.push('/projects/$projectId/development-log/edit/${log.id}');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Type Icon and Delete Button
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      log.logType.icon,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Title, Meta, and Status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title and Status Row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                log.title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Color(int.parse(
                                  log.status.colorHex.replaceFirst('#', '0xFF'),
                                )).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                log.status.displayName,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(int.parse(
                                    log.status.colorHex.replaceFirst('#', '0xFF'),
                                  )),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Meta information
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            if (log.userName != null) ...[
                              CircleAvatar(
                                radius: 10,
                                backgroundImage: log.userAvatar != null
                                    ? NetworkImage(log.userAvatar!)
                                    : null,
                                child: log.userAvatar == null
                                    ? Text(
                                        log.userName![0].toUpperCase(),
                                        style: const TextStyle(fontSize: 12),
                                      )
                                    : null,
                              ),
                              Text(
                                log.userName!,
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                            Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            Text(
                              DateFormat('yyyy-MM-dd').format(log.startDate),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            if (log.endDate != null)
                              Text(
                                ' ~ ${DateFormat('yyyy-MM-dd').format(log.endDate!)}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Delete Button
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    iconSize: 20,
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(8),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('개발 이력 삭제'),
                          content: const Text('이 개발 이력을 삭제하시겠습니까?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('취소'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('삭제'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        try {
                          await logsNotifier.deleteDevelopmentLog(log.id);
                          
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('개발 이력이 삭제되었습니다')),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('오류가 발생했습니다: $e'),
                                backgroundColor: theme.colorScheme.error,
                              ),
                            );
                          }
                        }
                      }
                    },
                  ),
                ],
              ),
              
              // Description
              if (log.description != null && log.description!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  log.description!,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              
              // Footer
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  // Type
                  Chip(
                    label: Text(log.logType.displayName),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                  // Hours
                  if (log.hoursSpent > 0)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${log.hoursSpent}h',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  // Related Task
                  if (log.taskTitle != null)
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.5,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.task_alt,
                            size: 16,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              log.taskTitle!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}