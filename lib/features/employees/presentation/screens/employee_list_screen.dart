import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

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

// Search Query Provider
final searchQueryProvider = StateProvider<String>((ref) => '');

// Filtered Employees Provider
final filteredEmployeesProvider = Provider<List<UserModel>>((ref) {
  final employees = ref.watch(employeesListProvider).valueOrNull ?? [];
  final searchQuery = ref.watch(searchQueryProvider).toLowerCase();
  
  if (searchQuery.isEmpty) {
    return employees;
  }
  
  return employees.where((employee) {
    final name = (employee.name ?? '').toLowerCase();
    final email = employee.email.toLowerCase();
    final phone = (employee.phone ?? '').toLowerCase();
    final department = (employee.department ?? '').toLowerCase();
    final division = (employee.division ?? '').toLowerCase();
    
    return name.contains(searchQuery) ||
        email.contains(searchQuery) ||
        phone.contains(searchQuery) ||
        department.contains(searchQuery) ||
        division.contains(searchQuery);
  }).toList();
});

class EmployeeListScreen extends ConsumerWidget {
  const EmployeeListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employeesAsync = ref.watch(employeesListProvider);
    final filteredEmployees = ref.watch(filteredEmployeesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('임직원 목록'),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surface,
            child: _SearchBar(),
          ),
          
          // Employee Count
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Theme.of(context).colorScheme.surface,
            child: employeesAsync.when(
              data: (employees) => Text(
                '총 ${employees.length}명',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),
          
          const Divider(height: 1),
          
          // Content
          Expanded(
            child: employeesAsync.when(
              data: (employees) {
                if (employees.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '등록된 임직원이 없습니다.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                if (filteredEmployees.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '검색 결과가 없습니다.',
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
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredEmployees.length,
                  itemBuilder: (context, index) {
                    final employee = filteredEmployees[index];
                    return _ModernEmployeeCard(employee: employee);
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
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Theme.of(context).colorScheme.error,
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
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 1,
        ),
      ),
      child: TextField(
        onChanged: (value) {
          ref.read(searchQueryProvider.notifier).state = value;
        },
        decoration: InputDecoration(
          hintText: '이름, 이메일, 전화번호, 부서명으로 검색',
          hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 14),
          prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.onSurfaceVariant),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}

class _ModernEmployeeCard extends ConsumerWidget {
  final UserModel employee;

  const _ModernEmployeeCard({
    required this.employee,
  });

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _launchPhone(String phone) async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: phone,
    );
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserAsync = ref.watch(userDetailsProvider);
    final currentUser = currentUserAsync.valueOrNull;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // 관리자는 모든 직원 정보 수정 가능
            // 일반 사용자는 자신의 정보만 수정 가능
            final isAdmin = currentUser?.role == 'admin';
            final isOwnProfile = currentUser?.id == employee.id;
            
            if (isAdmin || isOwnProfile) {
              context.push('/employees/edit/${employee.id}');
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('자신의 정보만 수정할 수 있습니다.'),
                  backgroundColor: AppColors.warning,
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Modern Avatar
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor.withValues(alpha: 0.8),
                        Theme.of(context).primaryColor,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: employee.avatarUrl != null
                      ? ClipOval(
                          child: Image.network(
                            employee.avatarUrl!,
                            key: ValueKey(employee.avatarUrl),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => _buildAvatarText(context),
                          ),
                        )
                      : _buildAvatarText(context),
                ),
                const SizedBox(width: 16),
                
                // Info Section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name and Role
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              employee.name ?? '이름 없음',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                          if (employee.role == 'admin')
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Colors.red, Colors.redAccent],
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '관리자',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onPrimary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      // Department & Position
                      if (employee.department != null || employee.position != null)
                        Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              if (employee.department != null)
                                _buildTag(
                                  employee.department!,
                                  Colors.blue,
                                  Icons.business,
                                ),
                              if (employee.department != null && employee.position != null)
                                const SizedBox(width: 8),
                              if (employee.position != null)
                                _buildTag(
                                  employee.position!,
                                  Colors.green,
                                  Icons.badge,
                                ),
                            ],
                          ),
                        ),
                      
                      // Contact Icons
                      Row(
                        children: [
                          // Email Icon
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              child: InkWell(
                                onTap: () => _launchEmail(employee.email),
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Icon(
                                    Icons.email_outlined,
                                    size: 20,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          
                          // Phone Icon
                          if (employee.phone != null && employee.phone!.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                child: InkWell(
                                  onTap: () => _launchPhone(employee.phone!),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Icon(
                                      Icons.phone_outlined,
                                      size: 20,
                                      color: AppColors.success,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Arrow Icon
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey[400],
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarText(BuildContext context) {
    return Center(
      child: Text(
        employee.name?.substring(0, 1).toUpperCase() ?? 
        employee.email.substring(0, 1).toUpperCase(),
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
} 