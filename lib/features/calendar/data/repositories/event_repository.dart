import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../shared/providers/supabase_provider.dart';
import '../models/event_model.dart';

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return EventRepository(supabase);
});

class EventRepository {
  final SupabaseClient _supabase;

  EventRepository(this._supabase);

  // Get all events for the current user
  Future<List<EventModel>> getEvents() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final response = await _supabase
        .from('events')
        .select()
        .eq('user_id', userId)
        .order('start_time', ascending: true);

    return (response as List)
        .map((json) => EventModel.fromJson(json))
        .toList();
  }

  // Get events for a specific date range
  Future<List<EventModel>> getEventsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final response = await _supabase
        .from('events')
        .select()
        .eq('user_id', userId)
        .gte('start_time', start.toIso8601String())
        .lte('end_time', end.toIso8601String())
        .order('start_time', ascending: true);

    return (response as List)
        .map((json) => EventModel.fromJson(json))
        .toList();
  }

  // Get events for a specific day
  Future<List<EventModel>> getEventsByDay(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return getEventsByDateRange(startOfDay, endOfDay);
  }

  // Create a new event
  Future<EventModel> createEvent(EventModel event) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final data = {
      'user_id': userId,
      'title': event.title,
      'description': event.description,
      'start_time': event.startTime.toIso8601String(),
      'end_time': event.endTime.toIso8601String(),
      'location': event.location,
      'event_type': event.eventType.name,
      'is_all_day': event.isAllDay,
    };

    final response = await _supabase
        .from('events')
        .insert(data)
        .select()
        .single();

    return EventModel.fromJson(response);
  }

  // Update an existing event
  Future<EventModel> updateEvent(EventModel event) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final data = {
      'title': event.title,
      'description': event.description,
      'start_time': event.startTime.toIso8601String(),
      'end_time': event.endTime.toIso8601String(),
      'location': event.location,
      'event_type': event.eventType.name,
      'is_all_day': event.isAllDay,
      'updated_at': DateTime.now().toIso8601String(),
    };

    final response = await _supabase
        .from('events')
        .update(data)
        .eq('id', event.id)
        .eq('user_id', userId)
        .select()
        .single();

    return EventModel.fromJson(response);
  }

  // Delete an event
  Future<void> deleteEvent(String eventId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    await _supabase
        .from('events')
        .delete()
        .eq('id', eventId)
        .eq('user_id', userId);
  }

  // Stream events for real-time updates
  Stream<List<EventModel>> streamEvents() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Stream.error('User not authenticated');

    return _supabase
        .from('events')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('start_time', ascending: true)
        .map((data) => data.map((json) => EventModel.fromJson(json)).toList());
  }

  // Stream events for a specific date range
  Stream<List<EventModel>> streamEventsByDateRange(
    DateTime start,
    DateTime end,
  ) {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Stream.error('User not authenticated');

    return _supabase
        .from('events')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .map((data) {
          // Filter by date range in memory
          final filteredData = data.where((json) {
            final eventStart = DateTime.parse(json['start_time'] as String);
            final eventEnd = DateTime.parse(json['end_time'] as String);
            return eventStart.isAfter(start.subtract(const Duration(seconds: 1))) &&
                   eventEnd.isBefore(end.add(const Duration(seconds: 1)));
          }).toList();
          
          // Sort by start time
          filteredData.sort((a, b) {
            final aStart = DateTime.parse(a['start_time'] as String);
            final bStart = DateTime.parse(b['start_time'] as String);
            return aStart.compareTo(bStart);
          });
          
          return filteredData.map((json) => EventModel.fromJson(json)).toList();
        });
  }
}