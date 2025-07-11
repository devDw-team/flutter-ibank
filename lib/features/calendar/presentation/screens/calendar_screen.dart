import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('일정'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              // TODO: Go to today
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('일정 화면'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Add new event
        },
        child: const Icon(Icons.add),
      ),
    );
  }
} 