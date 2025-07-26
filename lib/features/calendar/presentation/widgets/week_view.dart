import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/models/event_model.dart';
import '../providers/calendar_provider.dart';

class WeekView extends ConsumerWidget {
  const WeekView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final calendarActions = ref.watch(calendarActionsProvider);
    final eventsAsync = ref.watch(weekEventsProvider);

    // Calculate week dates
    final weekday = selectedDate.weekday;
    final startOfWeek = selectedDate.subtract(Duration(days: weekday - 1));
    final weekDates = List.generate(7, (i) => startOfWeek.add(Duration(days: i)));

    return Column(
      children: [
        // Week navigation header
        Container(
          color: Theme.of(context).colorScheme.surface,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  calendarActions.setSelectedDate(
                    selectedDate.subtract(const Duration(days: 7)),
                  );
                },
              ),
              Text(
                _getWeekRange(startOfWeek),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  calendarActions.setSelectedDate(
                    selectedDate.add(const Duration(days: 7)),
                  );
                },
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // Week days header
        Container(
          color: Theme.of(context).colorScheme.surface,
          height: 60,
          child: Row(
            children: weekDates.map((date) {
              final isToday = _isToday(date);
              final isSelected = _isSameDay(date, selectedDate);
              
              return Expanded(
                child: InkWell(
                  onTap: () => calendarActions.setSelectedDate(date),
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? AppColors.primary 
                          : isToday 
                              ? AppColors.primary.withValues(alpha: 0.1)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _getDayName(date.weekday),
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected 
                                ? Theme.of(context).colorScheme.onPrimary 
                                : date.weekday == 7 
                                    ? Theme.of(context).colorScheme.error 
                                    : Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          date.day.toString(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isSelected 
                                ? Theme.of(context).colorScheme.onPrimary 
                                : isToday
                                    ? AppColors.primary
                                    : date.weekday == 7 
                                        ? Theme.of(context).colorScheme.error 
                                        : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const Divider(height: 1),
        // Events view
        Expanded(
          child: eventsAsync.when(
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
                    onPressed: () => ref.invalidate(weekEventsProvider),
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            ),
            data: (events) {
              final eventsByDay = events.groupByDay();
              
              return SingleChildScrollView(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 2,
                    height: 24 * 60.0, // 24 hours * 60 pixels per hour
                    child: Row(
                      children: [
                        // Time column
                        SizedBox(
                          width: 60,
                          child: Column(
                            children: List.generate(24, (hour) {
                              return Container(
                                height: 60,
                                padding: const EdgeInsets.only(right: 8),
                                alignment: Alignment.topRight,
                                child: Text(
                                  '${hour.toString().padLeft(2, '0')}:00',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      // Days columns
                      ...weekDates.map((date) {
                        final dayEvents = eventsByDay[DateTime(date.year, date.month, date.day)] ?? [];
                        
                        return Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(color: Theme.of(context).dividerColor),
                              ),
                            ),
                            child: Stack(
                              children: [
                                // Hour grid lines
                                ...List.generate(24, (hour) {
                                  return Positioned(
                                    top: hour * 60.0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      height: 1,
                                      color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
                                    ),
                                  );
                                }),
                                // Events
                                ...dayEvents.map((event) {
                                  if (event.isAllDay) {
                                    return Positioned(
                                      top: 0,
                                      left: 4,
                                      right: 4,
                                      child: _buildAllDayEvent(context, event),
                                    );
                                  }
                                  
                                  final startMinutes = event.startTime.hour * 60 + event.startTime.minute;
                                  final duration = event.duration.inMinutes;
                                  
                                  return Positioned(
                                    top: startMinutes.toDouble(),
                                    left: 4,
                                    right: 4,
                                    height: duration.toDouble().clamp(30, double.infinity),
                                    child: _buildEvent(context, event),
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEvent(BuildContext context, EventModel event) {
    return InkWell(
      onTap: () => context.push('/calendar/detail/${event.id}'),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: _getEventColor(context, event.eventType).withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: _getEventColor(context, event.eventType),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (event.duration.inMinutes > 60)
              Text(
                _formatTime(event.startTime),
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllDayEvent(BuildContext context, EventModel event) {
    return InkWell(
      onTap: () => context.push('/calendar/detail/${event.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 2),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          color: _getEventColor(context, event.eventType),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          event.title,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  String _getWeekRange(DateTime startOfWeek) {
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    final format = DateFormat('MM월 dd일');
    return '${format.format(startOfWeek)} - ${format.format(endOfWeek)}';
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return '월';
      case 2: return '화';
      case 3: return '수';
      case 4: return '목';
      case 5: return '금';
      case 6: return '토';
      case 7: return '일';
      default: return '';
    }
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
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

  String _formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }
}