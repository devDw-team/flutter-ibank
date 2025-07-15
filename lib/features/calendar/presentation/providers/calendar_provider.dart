import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../data/models/event_model.dart';
import '../../data/repositories/event_repository.dart';

part 'calendar_provider.freezed.dart';

// Calendar view type
enum CalendarView { month, week, day }

// Selected date provider
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

// Calendar view provider
final calendarViewProvider = StateProvider<CalendarView>((ref) => CalendarView.month);

// Focused date for table_calendar
final focusedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

// Events stream provider
final eventsStreamProvider = StreamProvider.autoDispose<List<EventModel>>((ref) {
  final repository = ref.watch(eventRepositoryProvider);
  return repository.streamEvents();
});

// Events for selected month
final monthEventsProvider = StreamProvider.autoDispose<List<EventModel>>((ref) {
  final repository = ref.watch(eventRepositoryProvider);
  final focusedDate = ref.watch(focusedDateProvider);
  
  final startOfMonth = DateTime(focusedDate.year, focusedDate.month, 1);
  final endOfMonth = DateTime(focusedDate.year, focusedDate.month + 1, 0, 23, 59, 59);
  
  return repository.streamEventsByDateRange(startOfMonth, endOfMonth);
});

// Events for selected week
final weekEventsProvider = StreamProvider.autoDispose<List<EventModel>>((ref) {
  final repository = ref.watch(eventRepositoryProvider);
  final selectedDate = ref.watch(selectedDateProvider);
  
  // Get start of week (Monday)
  final weekday = selectedDate.weekday;
  final startOfWeek = selectedDate.subtract(Duration(days: weekday - 1));
  final endOfWeek = startOfWeek.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
  
  return repository.streamEventsByDateRange(startOfWeek, endOfWeek);
});

// Events for selected day
final dayEventsProvider = FutureProvider.autoDispose<List<EventModel>>((ref) async {
  final repository = ref.watch(eventRepositoryProvider);
  final selectedDate = ref.watch(selectedDateProvider);
  
  return repository.getEventsByDay(selectedDate);
});

// Calendar state
@freezed
class CalendarState with _$CalendarState {
  const factory CalendarState({
    @Default(false) bool isLoading,
    String? error,
  }) = _CalendarState;
}

// Calendar actions provider
final calendarActionsProvider = Provider<CalendarActions>((ref) {
  return CalendarActions(ref);
});

class CalendarActions {
  final ProviderRef _ref;

  CalendarActions(this._ref);

  EventRepository get _repository => _ref.read(eventRepositoryProvider);

  Future<EventModel> createEvent(EventModel event) async {
    try {
      final newEvent = await _repository.createEvent(event);
      return newEvent;
    } catch (e) {
      throw Exception('Failed to create event: $e');
    }
  }

  Future<EventModel> updateEvent(EventModel event) async {
    try {
      final updatedEvent = await _repository.updateEvent(event);
      return updatedEvent;
    } catch (e) {
      throw Exception('Failed to update event: $e');
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      await _repository.deleteEvent(eventId);
    } catch (e) {
      throw Exception('Failed to delete event: $e');
    }
  }

  void setSelectedDate(DateTime date) {
    _ref.read(selectedDateProvider.notifier).state = date;
  }

  void setFocusedDate(DateTime date) {
    _ref.read(focusedDateProvider.notifier).state = date;
  }

  void setCalendarView(CalendarView view) {
    _ref.read(calendarViewProvider.notifier).state = view;
  }

  void goToToday() {
    final now = DateTime.now();
    _ref.read(selectedDateProvider.notifier).state = now;
    _ref.read(focusedDateProvider.notifier).state = now;
  }
}

// Helper to get events for a specific day from a list
extension EventListX on List<EventModel> {
  List<EventModel> getEventsForDay(DateTime day) {
    return where((event) {
      final eventDate = DateTime(
        event.startTime.year,
        event.startTime.month,
        event.startTime.day,
      );
      final targetDate = DateTime(day.year, day.month, day.day);
      return eventDate == targetDate;
    }).toList();
  }

  Map<DateTime, List<EventModel>> groupByDay() {
    final Map<DateTime, List<EventModel>> eventsByDay = {};
    
    for (final event in this) {
      final day = DateTime(
        event.startTime.year,
        event.startTime.month,
        event.startTime.day,
      );
      
      if (eventsByDay.containsKey(day)) {
        eventsByDay[day]!.add(event);
      } else {
        eventsByDay[day] = [event];
      }
    }
    
    return eventsByDay;
  }
}