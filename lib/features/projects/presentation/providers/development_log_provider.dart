import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../shared/providers/supabase_provider.dart';
import '../../data/models/development_log.dart';
import '../../data/repositories/development_log_repository.dart';

// Repository provider
final developmentLogRepositoryProvider = Provider<DevelopmentLogRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return DevelopmentLogRepository(supabase);
});

// Development logs state
class DevelopmentLogsState {
  final List<DevelopmentLog> logs;
  final bool isLoading;
  final String? error;

  DevelopmentLogsState({
    required this.logs,
    required this.isLoading,
    this.error,
  });

  DevelopmentLogsState copyWith({
    List<DevelopmentLog>? logs,
    bool? isLoading,
    String? error,
  }) {
    return DevelopmentLogsState(
      logs: logs ?? this.logs,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Development logs notifier
class DevelopmentLogsNotifier extends StateNotifier<DevelopmentLogsState> {
  final DevelopmentLogRepository _repository;
  final String projectId;
  StreamSubscription? _subscription;

  DevelopmentLogsNotifier(this._repository, this.projectId)
      : super(DevelopmentLogsState(logs: [], isLoading: true)) {
    _initialize();
  }

  Future<void> _initialize() async {
    await loadDevelopmentLogs();
    _setupRealtimeListener();
  }

  Future<void> loadDevelopmentLogs() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final logs = await _repository.getDevelopmentLogs(projectId);
      state = state.copyWith(logs: logs, isLoading: false);
    } catch (e) {
      print('loadDevelopmentLogs error: $e');
      state = state.copyWith(
        isLoading: false,
        error: '개발 이력을 불러오는데 실패했습니다',
      );
    }
  }

  void _setupRealtimeListener() {
    _subscription = _repository.streamDevelopmentLogs(projectId).listen(
      (logs) {
        state = state.copyWith(logs: logs);
      },
      onError: (error) {
        state = state.copyWith(error: '실시간 업데이트 오류');
      },
    );
  }

  Future<void> createDevelopmentLog({
    required String title,
    String? description,
    required DevelopmentLogType logType,
    required DevelopmentLogStatus status,
    required DateTime startDate,
    DateTime? endDate,
    double hoursSpent = 0.0,
    String? relatedTaskId,
    List<String> attachments = const [],
  }) async {
    try {
      state = state.copyWith(error: null);
      
      final newLog = await _repository.createDevelopmentLog(
        projectId: projectId,
        title: title,
        description: description,
        logType: logType,
        status: status,
        startDate: startDate,
        endDate: endDate,
        hoursSpent: hoursSpent,
        relatedTaskId: relatedTaskId,
        attachments: attachments,
      );

      // Add to local state immediately for better UX
      state = state.copyWith(
        logs: [newLog, ...state.logs],
      );
    } catch (e) {
      state = state.copyWith(error: '개발 이력 생성 실패');
      rethrow;
    }
  }

  Future<void> updateDevelopmentLog({
    required String logId,
    String? title,
    String? description,
    DevelopmentLogType? logType,
    DevelopmentLogStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    double? hoursSpent,
    String? relatedTaskId,
    List<String>? attachments,
  }) async {
    try {
      state = state.copyWith(error: null);
      
      final updatedLog = await _repository.updateDevelopmentLog(
        logId: logId,
        title: title,
        description: description,
        logType: logType,
        status: status,
        startDate: startDate,
        endDate: endDate,
        hoursSpent: hoursSpent,
        relatedTaskId: relatedTaskId,
        attachments: attachments,
      );

      // Update local state immediately
      state = state.copyWith(
        logs: state.logs.map((log) {
          return log.id == logId ? updatedLog : log;
        }).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: '개발 이력 수정 실패');
      rethrow;
    }
  }

  Future<void> deleteDevelopmentLog(String logId) async {
    try {
      state = state.copyWith(error: null);
      
      await _repository.deleteDevelopmentLog(logId);

      // Remove from local state immediately
      state = state.copyWith(
        logs: state.logs.where((log) => log.id != logId).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: '개발 이력 삭제 실패');
      rethrow;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

// Development logs provider
final developmentLogsProvider = StateNotifierProvider.family
    .autoDispose<DevelopmentLogsNotifier, DevelopmentLogsState, String>(
  (ref, projectId) {
    final repository = ref.watch(developmentLogRepositoryProvider);
    return DevelopmentLogsNotifier(repository, projectId);
  },
);

// Development log statistics provider - reactive to logs changes
final developmentLogStatsProvider =
    Provider.family.autoDispose<AsyncValue<Map<String, dynamic>>, String>(
  (ref, projectId) {
    // Watch the logs to trigger recalculation when they change
    final logsState = ref.watch(developmentLogsProvider(projectId));
    
    if (logsState.isLoading) {
      return const AsyncValue.loading();
    }
    
    if (logsState.error != null) {
      return AsyncValue.error(logsState.error!, StackTrace.current);
    }
    
    // Calculate statistics from the current logs
    final logs = logsState.logs;
    double totalHours = 0;
    final statusCounts = <String, int>{};
    final typeCounts = <String, int>{};
    
    for (final log in logs) {
      totalHours += log.hoursSpent;
      
      // Count by status
      final statusKey = _getStatusValue(log.status);
      statusCounts[statusKey] = (statusCounts[statusKey] ?? 0) + 1;
      
      // Count by type
      final typeKey = _getLogTypeValue(log.logType);
      typeCounts[typeKey] = (typeCounts[typeKey] ?? 0) + 1;
    }
    
    return AsyncValue.data({
      'totalHours': totalHours,
      'statusCounts': statusCounts,
      'typeCounts': typeCounts,
      'totalLogs': logs.length,
    });
  },
);

// Helper functions for stats calculation
String _getStatusValue(DevelopmentLogStatus status) {
  switch (status) {
    case DevelopmentLogStatus.inProgress:
      return 'in_progress';
    case DevelopmentLogStatus.completed:
      return 'completed';
    case DevelopmentLogStatus.testing:
      return 'testing';
    case DevelopmentLogStatus.deployed:
      return 'deployed';
  }
}

String _getLogTypeValue(DevelopmentLogType type) {
  switch (type) {
    case DevelopmentLogType.feature:
      return 'feature';
    case DevelopmentLogType.bugfix:
      return 'bugfix';
    case DevelopmentLogType.refactor:
      return 'refactor';
    case DevelopmentLogType.performance:
      return 'performance';
    case DevelopmentLogType.ui:
      return 'ui';
    case DevelopmentLogType.backend:
      return 'backend';
    case DevelopmentLogType.other:
      return 'other';
  }
}

// Filter development logs by status
final filteredDevelopmentLogsProvider = Provider.family
    .autoDispose<List<DevelopmentLog>, (String, DevelopmentLogStatus?)>(
  (ref, params) {
    final (projectId, status) = params;
    final logsState = ref.watch(developmentLogsProvider(projectId));
    
    if (status == null) {
      return logsState.logs;
    }
    
    return logsState.logs.where((log) => log.status == status).toList();
  },
);

// Filter development logs by type
final developmentLogsByTypeProvider = Provider.family
    .autoDispose<List<DevelopmentLog>, (String, DevelopmentLogType?)>(
  (ref, params) {
    final (projectId, type) = params;
    final logsState = ref.watch(developmentLogsProvider(projectId));
    
    if (type == null) {
      return logsState.logs;
    }
    
    return logsState.logs.where((log) => log.logType == type).toList();
  },
);