import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('프로젝트'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () {
              // TODO: Show sort options
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('프로젝트 화면'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Create new project
        },
        child: const Icon(Icons.add),
      ),
    );
  }
} 