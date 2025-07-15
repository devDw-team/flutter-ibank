import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/models/event_model.dart';
import '../providers/calendar_provider.dart';

class DayView extends ConsumerWidget {
  const DayView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final calendarActions = ref.watch(calendarActionsProvider);
    final eventsAsync = ref.watch(dayEventsProvider);

    return Column(
      children: [
        // Day navigation header
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  calendarActions.setSelectedDate(
                    selectedDate.subtract(const Duration(days: 1)),
                  );
                },
              ),
              Column(
                children: [
                  Text(
                    DateFormat('yyyy년 MM월 dd일').format(selectedDate),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _getDayName(selectedDate.weekday),
                    style: TextStyle(
                      fontSize: 14,
                      color: selectedDate.weekday == 7 ? Colors.red : Colors.grey[600],
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  calendarActions.setSelectedDate(
                    selectedDate.add(const Duration(days: 1)),
                  );
                },
              ),
            ],
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
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('오류: $error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(dayEventsProvider),
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            ),
            data: (events) {
              if (events.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_busy,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '일정이 없습니다',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '새로운 일정을 추가해보세요',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Separate all-day events and timed events
              final allDayEvents = events.where((e) => e.isAllDay).toList();
              final timedEvents = events.where((e) => !e.isAllDay).toList()
                ..sort((a, b) => a.startTime.compareTo(b.startTime));

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // All-day events section
                    if (allDayEvents.isNotEmpty) ...[
                      Row(
                        children: [
                          Icon(Icons.wb_sunny, size: 20, color: Colors.grey[700]),
                          const SizedBox(width: 8),
                          Text(
                            '종일 일정',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...allDayEvents.map((event) => _buildEventCard(context, event, isAllDay: true)),
                      const SizedBox(height: 24),
                    ],
                    
                    // Timed events section
                    if (timedEvents.isNotEmpty) ...[
                      Row(
                        children: [
                          Icon(Icons.schedule, size: 20, color: Colors.grey[700]),
                          const SizedBox(width: 8),
                          Text(
                            '시간별 일정',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...timedEvents.map((event) => _buildEventCard(context, event)),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEventCard(BuildContext context, EventModel event, {bool isAllDay = false}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: InkWell(
        onTap: () => context.push('/calendar/detail/${event.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 100,
              decoration: BoxDecoration(
                color: _getEventColor(event.eventType),
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(12),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            event.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Chip(
                          label: Text(
                            event.eventTypeText,
                            style: const TextStyle(fontSize: 12),
                          ),
                          backgroundColor: _getEventColor(event.eventType).withOpacity(0.2),
                          side: BorderSide.none,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          isAllDay ? '종일' : _formatTimeRange(event),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (!isAllDay) ...[
                          const SizedBox(width: 16),
                          Icon(Icons.timer, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            _formatDuration(event.duration),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (event.location != null && event.location!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              event.location!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (event.description != null && event.description!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        event.description!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return '월요일';
      case 2: return '화요일';
      case 3: return '수요일';
      case 4: return '목요일';
      case 5: return '금요일';
      case 6: return '토요일';
      case 7: return '일요일';
      default: return '';
    }
  }

  Color _getEventColor(EventType type) {
    switch (type) {
      case EventType.personal:
        return Colors.blue;
      case EventType.team:
        return Colors.green;
      case EventType.company:
        return Colors.purple;
      case EventType.meeting:
        return Colors.orange;
    }
  }

  String _formatTimeRange(EventModel event) {
    final timeFormat = DateFormat('HH:mm');
    return '${timeFormat.format(event.startTime)} - ${timeFormat.format(event.endTime)}';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    if (hours > 0 && minutes > 0) {
      return '$hours시간 $minutes분';
    } else if (hours > 0) {
      return '$hours시간';
    } else {
      return '$minutes분';
    }
  }
}