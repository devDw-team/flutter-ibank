import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('할 일'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Show filter options
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('할 일 화면'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Add new task
        },
        child: const Icon(Icons.add),
      ),
    );
  }
} 