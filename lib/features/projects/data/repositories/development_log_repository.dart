import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/development_log.dart';

class DevelopmentLogRepository {
  final SupabaseClient _supabase;

  DevelopmentLogRepository(this._supabase);
  
  // Helper method to get log type value
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
  
  // Helper method to get status value
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

  // Get all development logs for a project
  Future<List<DevelopmentLog>> getDevelopmentLogs(String projectId) async {
    try {
      print('getDevelopmentLogs called with projectId: $projectId');
      final response = await _supabase
          .from('development_logs')
          .select()
          .eq('project_id', projectId)
          .order('created_at', ascending: false);
      
      print('getDevelopmentLogs response: ${response.length} items');

      // Convert response to list of DevelopmentLog objects
      final logs = <DevelopmentLog>[];
      
      for (final json in response as List) {
        final flatJson = Map<String, dynamic>.from(json);
        
        // Fetch user info if user_id exists
        if (json['user_id'] != null) {
          try {
            final userResponse = await _supabase
                .from('users')
                .select('name, avatar_url')
                .eq('id', json['user_id'])
                .maybeSingle();
            
            if (userResponse != null) {
              flatJson['userName'] = userResponse['name'];
              flatJson['userAvatar'] = userResponse['avatar_url'];
            }
          } catch (e) {
            print('Error fetching user info: $e');
          }
        }
        
        // Fetch task info if related_task_id exists
        if (json['related_task_id'] != null) {
          try {
            final taskResponse = await _supabase
                .from('tasks')
                .select('title')
                .eq('id', json['related_task_id'])
                .maybeSingle();
            
            if (taskResponse != null) {
              flatJson['taskTitle'] = taskResponse['title'];
            }
          } catch (e) {
            print('Error fetching task info: $e');
          }
        }
        
        logs.add(DevelopmentLog.fromJson(flatJson));
      }
      
      return logs;
    } catch (e, stack) {
      print('getDevelopmentLogs error: $e');
      print('Stack trace: $stack');
      throw Exception('Failed to load development logs');
    }
  }

  // Get a single development log
  Future<DevelopmentLog?> getDevelopmentLog(String logId) async {
    try {
      final response = await _supabase
          .from('development_logs')
          .select()
          .eq('id', logId)
          .maybeSingle();

      if (response == null) return null;

      final flatJson = Map<String, dynamic>.from(response);
      
      // Fetch user info if user_id exists
      if (response['user_id'] != null) {
        try {
          final userResponse = await _supabase
              .from('users')
              .select('name, avatar_url')
              .eq('id', response['user_id'])
              .maybeSingle();
          
          if (userResponse != null) {
            flatJson['userName'] = userResponse['name'];
            flatJson['userAvatar'] = userResponse['avatar_url'];
          }
        } catch (e) {
          print('Error fetching user info: $e');
        }
      }
      
      // Fetch task info if related_task_id exists
      if (response['related_task_id'] != null) {
        try {
          final taskResponse = await _supabase
              .from('tasks')
              .select('title')
              .eq('id', response['related_task_id'])
              .maybeSingle();
          
          if (taskResponse != null) {
            flatJson['taskTitle'] = taskResponse['title'];
          }
        } catch (e) {
          print('Error fetching task info: $e');
        }
      }

      return DevelopmentLog.fromJson(flatJson);
    } catch (e) {
      throw Exception('Failed to load development log');
    }
  }

  // Create a new development log
  Future<DevelopmentLog> createDevelopmentLog({
    required String projectId,
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
      print('createDevelopmentLog called');
      print('projectId: $projectId, title: $title, logType: ${logType.name}, status: ${status.name}');
      
      final userId = _supabase.auth.currentUser!.id;
      print('userId: $userId');
      
      final response = await _supabase
          .from('development_logs')
          .insert({
            'project_id': projectId,
            'user_id': userId,
            'title': title,
            'description': description,
            'log_type': _getLogTypeValue(logType),
            'status': _getStatusValue(status),
            'start_date': startDate.toIso8601String(),
            'end_date': endDate?.toIso8601String(),
            'hours_spent': hoursSpent,
            'related_task_id': relatedTaskId,
            'attachments': attachments,
          })
          .select()
          .single();

      final flatJson = Map<String, dynamic>.from(response);
      
      // Fetch user info
      try {
        final userResponse = await _supabase
            .from('users')
            .select('name, avatar_url')
            .eq('id', userId)
            .maybeSingle();
        
        if (userResponse != null) {
          flatJson['userName'] = userResponse['name'];
          flatJson['userAvatar'] = userResponse['avatar_url'];
        }
      } catch (e) {
        print('Error fetching user info: $e');
      }
      
      // Fetch task info if related_task_id exists
      if (relatedTaskId != null) {
        try {
          final taskResponse = await _supabase
              .from('tasks')
              .select('title')
              .eq('id', relatedTaskId)
              .maybeSingle();
          
          if (taskResponse != null) {
            flatJson['taskTitle'] = taskResponse['title'];
          }
        } catch (e) {
          print('Error fetching task info: $e');
        }
      }

      return DevelopmentLog.fromJson(flatJson);
    } catch (e, stack) {
      print('createDevelopmentLog error: $e');
      print('Stack trace: $stack');
      throw Exception('Failed to create development log');
    }
  }

  // Update a development log
  Future<DevelopmentLog> updateDevelopmentLog({
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
      final updates = <String, dynamic>{};
      
      if (title != null) updates['title'] = title;
      if (description != null) updates['description'] = description;
      if (logType != null) updates['log_type'] = _getLogTypeValue(logType);
      if (status != null) updates['status'] = _getStatusValue(status);
      if (startDate != null) updates['start_date'] = startDate.toIso8601String();
      if (endDate != null) updates['end_date'] = endDate.toIso8601String();
      if (hoursSpent != null) updates['hours_spent'] = hoursSpent;
      if (relatedTaskId != null) updates['related_task_id'] = relatedTaskId;
      if (attachments != null) updates['attachments'] = attachments;

      final response = await _supabase
          .from('development_logs')
          .update(updates)
          .eq('id', logId)
          .select()
          .single();

      final flatJson = Map<String, dynamic>.from(response);
      
      // Fetch user info if user_id exists
      if (response['user_id'] != null) {
        try {
          final userResponse = await _supabase
              .from('users')
              .select('name, avatar_url')
              .eq('id', response['user_id'])
              .maybeSingle();
          
          if (userResponse != null) {
            flatJson['userName'] = userResponse['name'];
            flatJson['userAvatar'] = userResponse['avatar_url'];
          }
        } catch (e) {
          print('Error fetching user info: $e');
        }
      }
      
      // Fetch task info if related_task_id exists
      if (response['related_task_id'] != null) {
        try {
          final taskResponse = await _supabase
              .from('tasks')
              .select('title')
              .eq('id', response['related_task_id'])
              .maybeSingle();
          
          if (taskResponse != null) {
            flatJson['taskTitle'] = taskResponse['title'];
          }
        } catch (e) {
          print('Error fetching task info: $e');
        }
      }

      return DevelopmentLog.fromJson(flatJson);
    } catch (e) {
      throw Exception('Failed to update development log');
    }
  }

  // Delete a development log
  Future<void> deleteDevelopmentLog(String logId) async {
    try {
      await _supabase
          .from('development_logs')
          .delete()
          .eq('id', logId);
    } catch (e) {
      throw Exception('Failed to delete development log');
    }
  }

  // Stream development logs for real-time updates
  Stream<List<DevelopmentLog>> streamDevelopmentLogs(String projectId) {
    return _supabase
        .from('development_logs')
        .stream(primaryKey: ['id'])
        .eq('project_id', projectId)
        .order('created_at', ascending: false)
        .asyncMap((logs) async {
          // Process each log to add user and task information
          final processedLogs = <DevelopmentLog>[];
          
          for (final log in logs) {
            final flatJson = Map<String, dynamic>.from(log);
            
            // Fetch user info if user_id exists
            if (log['user_id'] != null) {
              try {
                final userResponse = await _supabase
                    .from('users')
                    .select('name, avatar_url')
                    .eq('id', log['user_id'])
                    .maybeSingle();
                
                if (userResponse != null) {
                  flatJson['userName'] = userResponse['name'];
                  flatJson['userAvatar'] = userResponse['avatar_url'];
                }
              } catch (e) {
                print('Error fetching user info in stream: $e');
              }
            }
            
            // Fetch task info if related_task_id exists
            if (log['related_task_id'] != null) {
              try {
                final taskResponse = await _supabase
                    .from('tasks')
                    .select('title')
                    .eq('id', log['related_task_id'])
                    .maybeSingle();
                
                if (taskResponse != null) {
                  flatJson['taskTitle'] = taskResponse['title'];
                }
              } catch (e) {
                print('Error fetching task info in stream: $e');
              }
            }
            
            processedLogs.add(DevelopmentLog.fromJson(flatJson));
          }
          
          return processedLogs;
        });
  }

  // Get development logs statistics
  Future<Map<String, dynamic>> getDevelopmentLogStats(String projectId) async {
    try {
      // Get total hours spent
      final hoursResponse = await _supabase
          .from('development_logs')
          .select('hours_spent')
          .eq('project_id', projectId);
      
      double totalHours = 0;
      if (hoursResponse is List) {
        for (final log in hoursResponse) {
          totalHours += (log['hours_spent'] ?? 0).toDouble();
        }
      }

      // Get logs count by status
      final statusResponse = await _supabase
          .from('development_logs')
          .select('status')
          .eq('project_id', projectId);
      
      final statusCounts = <String, int>{};
      if (statusResponse is List) {
        for (final log in statusResponse) {
          final status = log['status'] as String;
          statusCounts[status] = (statusCounts[status] ?? 0) + 1;
        }
      }

      // Get logs count by type
      final typeResponse = await _supabase
          .from('development_logs')
          .select('log_type')
          .eq('project_id', projectId);
      
      final typeCounts = <String, int>{};
      if (typeResponse is List) {
        for (final log in typeResponse) {
          final type = log['log_type'] as String;
          typeCounts[type] = (typeCounts[type] ?? 0) + 1;
        }
      }

      return {
        'totalHours': totalHours,
        'statusCounts': statusCounts,
        'typeCounts': typeCounts,
        'totalLogs': (statusResponse as List).length,
      };
    } catch (e) {
      throw Exception('Failed to get development log statistics');
    }
  }
}