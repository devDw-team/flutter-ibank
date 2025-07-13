import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../features/auth/data/models/user_model.dart';
import '../../../../shared/providers/supabase_provider.dart';

// Employees List Provider
final employeesListProvider = FutureProvider<List<UserModel>>((ref) async {
  final supabase = ref.read(supabaseClientProvider);
  
  try {
    final data = await supabase
        .from('users')
        .select()
        .order('name', ascending: true);
    
    return data.map((json) => UserModel.fromJson(json)).toList();
  } catch (e) {
    throw Exception('Failed to load employees: $e');
  }
});

class EmployeeListScreen extends ConsumerWidget {
  const EmployeeListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employeesAsync = ref.watch(employeesListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('임직원 목록'),
      ),
      body: employeesAsync.when(
        data: (employees) {
          if (employees.isEmpty) {
            return const Center(
              child: Text('등록된 임직원이 없습니다.'),
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: employees.length,
            itemBuilder: (context, index) {
              final employee = employees[index];
              return _EmployeeCard(employee: employee);
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text('오류: $error'),
              const SizedBox(height: 16),
              FilledButton.tonal(
                onPressed: () {
                  ref.invalidate(employeesListProvider);
                },
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmployeeCard extends StatelessWidget {
  final UserModel employee;

  const _EmployeeCard({
    required this.employee,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 35,
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              backgroundImage: employee.avatarUrl != null
                  ? NetworkImage(employee.avatarUrl!)
                  : null,
              child: employee.avatarUrl == null
                  ? Text(
                      employee.name?.substring(0, 1).toUpperCase() ?? 
                      employee.email.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and Role Badge
                  Row(
                    children: [
                      Text(
                        employee.name ?? '이름 없음',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (employee.role == 'admin') ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '관리자',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  
                  // Email
                  Row(
                    children: [
                      Icon(
                        Icons.email_outlined,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        employee.email,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  
                  // Phone
                  if (employee.phone != null && employee.phone!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.phone_outlined,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          employee.phone!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                  
                  const SizedBox(height: 8),
                  
                  // Department Info
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      if (employee.division != null && employee.division!.isNotEmpty)
                        _InfoChip(
                          icon: Icons.business_outlined,
                          label: employee.division!,
                        ),
                      if (employee.department != null && employee.department!.isNotEmpty)
                        _InfoChip(
                          icon: Icons.group_work_outlined,
                          label: employee.department!,
                        ),
                      if (employee.position != null && employee.position!.isNotEmpty)
                        _InfoChip(
                          icon: Icons.badge_outlined,
                          label: employee.position!,
                        ),
                    ],
                  ),
                  
                  // Birthday
                  if (employee.birthday != null && employee.birthday!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.cake_outlined,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '생일: ${employee.birthday}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }
} 