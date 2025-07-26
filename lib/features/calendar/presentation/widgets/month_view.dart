import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/models/event_model.dart';
import '../providers/calendar_provider.dart';

class MonthView extends ConsumerStatefulWidget {
  const MonthView({super.key});

  @override
  ConsumerState<MonthView> createState() => _MonthViewState();
}

class _MonthViewState extends ConsumerState<MonthView> {
  late final ValueNotifier<List<EventModel>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _selectedEvents = ValueNotifier([]);
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<EventModel> _getEventsForDay(DateTime day, List<EventModel> allEvents) {
    return allEvents.getEventsForDay(day);
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedDateProvider);
    final focusedDate = ref.watch(focusedDateProvider);
    final calendarActions = ref.watch(calendarActionsProvider);
    final eventsAsync = ref.watch(monthEventsProvider);

    return eventsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text('오류: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.invalidate(monthEventsProvider),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
      data: (events) {
        _selectedEvents.value = _getEventsForDay(selectedDate, events);

        return Column(
          children: [
            Card(
              margin: const EdgeInsets.all(16),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Theme.of(context).dividerColor),
              ),
              child: TableCalendar<EventModel>(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: focusedDate,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) => isSameDay(selectedDate, day),
                eventLoader: (day) => _getEventsForDay(day, events),
                startingDayOfWeek: StartingDayOfWeek.monday,
                locale: 'ko_KR',
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  leftChevronIcon: const Icon(Icons.chevron_left),
                  rightChevronIcon: const Icon(Icons.chevron_right),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                ),
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  weekendTextStyle: TextStyle(color: Theme.of(context).colorScheme.error),
                  selectedDecoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: BoxDecoration(
                    color: AppColors.primaryDark,
                    shape: BoxShape.circle,
                  ),
                  markersMaxCount: 3,
                  markerSize: 6,
                  markerMargin: const EdgeInsets.symmetric(horizontal: 0.3),
                ),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, day, events) {
                    if (events.isEmpty) return null;
                    
                    return Positioned(
                      bottom: 4,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: events.take(3).map((event) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            height: 6,
                            width: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _getEventColor(context, event.eventType),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
                onDaySelected: (selectedDay, focusedDay) {
                  calendarActions.setSelectedDate(selectedDay);
                  calendarActions.setFocusedDate(focusedDay);
                  _selectedEvents.value = _getEventsForDay(selectedDay, events);
                },
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                onPageChanged: (focusedDay) {
                  calendarActions.setFocusedDate(focusedDay);
                },
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ValueListenableBuilder<List<EventModel>>(
                valueListenable: _selectedEvents,
                builder: (context, value, _) {
                  if (value.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_busy,
                            size: 48,
                            color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '선택한 날짜에 일정이 없습니다',
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: value.length,
                    itemBuilder: (context, index) {
                      final event = value[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Theme.of(context).dividerColor),
                        ),
                        child: ListTile(
                          onTap: () {
                            context.push('/calendar/detail/${event.id}');
                          },
                          leading: Container(
                            width: 4,
                            decoration: BoxDecoration(
                              color: _getEventColor(context, event.eventType),
                              borderRadius: const BorderRadius.horizontal(
                                left: Radius.circular(8),
                              ),
                            ),
                          ),
                          title: Text(
                            event.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _formatEventTime(event),
                                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                              ),
                              if (event.location != null && event.location!.isNotEmpty)
                                Row(
                                  children: [
                                    Icon(Icons.location_on, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                                    const SizedBox(width: 4),
                                    Text(
                                      event.location!,
                                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                          trailing: Chip(
                            label: Text(
                              event.eventTypeText,
                              style: const TextStyle(fontSize: 12),
                            ),
                            backgroundColor: _getEventColor(context, event.eventType).withValues(alpha: 0.2),
                            side: BorderSide.none,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Color _getEventColor(BuildContext context, EventType type) {
    switch (type) {
      case EventType.personal:
        return AppColors.primary;
      case EventType.team:
        return AppColors.success;
      case EventType.company:
        return Theme.of(context).colorScheme.secondary;
      case EventType.meeting:
        return AppColors.warning;
    }
  }

  String _formatEventTime(EventModel event) {
    if (event.isAllDay) {
      return '종일';
    }
    
    final startHour = event.startTime.hour.toString().padLeft(2, '0');
    final startMinute = event.startTime.minute.toString().padLeft(2, '0');
    final endHour = event.endTime.hour.toString().padLeft(2, '0');
    final endMinute = event.endTime.minute.toString().padLeft(2, '0');
    
    return '$startHour:$startMinute - $endHour:$endMinute';
  }
}