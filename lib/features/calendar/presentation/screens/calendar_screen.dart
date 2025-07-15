import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/models/event_model.dart';
import '../providers/calendar_provider.dart';
import '../widgets/month_view.dart';
import '../widgets/week_view.dart';
import '../widgets/day_view.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarView = ref.watch(calendarViewProvider);
    final calendarActions = ref.watch(calendarActionsProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('일정'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          // View type selector
          PopupMenuButton<CalendarView>(
            initialValue: calendarView,
            onSelected: (view) {
              calendarActions.setCalendarView(view);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: CalendarView.month,
                child: Text('월별'),
              ),
              const PopupMenuItem(
                value: CalendarView.week,
                child: Text('주별'),
              ),
              const PopupMenuItem(
                value: CalendarView.day,
                child: Text('일별'),
              ),
            ],
            icon: const Icon(Icons.view_module),
          ),
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              calendarActions.goToToday();
            },
            tooltip: '오늘',
          ),
        ],
      ),
      body: _buildCalendarView(calendarView),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/calendar/add');
        },
        label: const Text('일정 추가'),
        icon: const Icon(Icons.add),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildCalendarView(CalendarView view) {
    switch (view) {
      case CalendarView.month:
        return const MonthView();
      case CalendarView.week:
        return const WeekView();
      case CalendarView.day:
        return const DayView();
    }
  }
} 