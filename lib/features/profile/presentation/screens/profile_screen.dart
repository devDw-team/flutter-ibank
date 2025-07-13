import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/providers/supabase_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final userDetailsAsync = ref.watch(userDetailsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('마이'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      currentUser?.email?.substring(0, 1).toUpperCase() ?? 'U',
                      style: const TextStyle(
                        fontSize: 40,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    currentUser?.email ?? '',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  userDetailsAsync.when(
                    data: (userDetails) {
                      if (userDetails?.role == 'admin') {
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
                        );
                      }
                      return const SizedBox.shrink();
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Admin Menu Items
            userDetailsAsync.when(
              data: (userDetails) {
                if (userDetails?.role == 'admin') {
                  return _MenuSection(
                    title: '관리자 메뉴',
                    items: [
                      _MenuItem(
                        icon: Icons.group_add_outlined,
                        title: '임직원 전체 등록',
                        onTap: () {
                          context.push('/employee-registration');
                        },
                      ),
                      _MenuItem(
                        icon: Icons.person_add_outlined,
                        title: '임직원 등록',
                        onTap: () {
                          context.push('/employee-add');
                        },
                      ),
                      _MenuItem(
                        icon: Icons.people_outlined,
                        title: '임직원 목록',
                        onTap: () {
                          context.push('/employee-list');
                        },
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            
            // Menu Items
            _MenuSection(
              title: '계정',
              items: [
                _MenuItem(
                  icon: Icons.person_outline,
                  title: '프로필 편집',
                  onTap: () {
                    // TODO: Navigate to profile edit
                  },
                ),
                _MenuItem(
                  icon: Icons.lock_outline,
                  title: '비밀번호 변경',
                  onTap: () {
                    // TODO: Navigate to password change
                  },
                ),
              ],
            ),
            
            _MenuSection(
              title: '설정',
              items: [
                _MenuItem(
                  icon: Icons.notifications_outlined,
                  title: '알림 설정',
                  onTap: () {
                    // TODO: Navigate to notification settings
                  },
                ),
                _MenuItem(
                  icon: Icons.language,
                  title: '언어 설정',
                  onTap: () {
                    // TODO: Navigate to language settings
                  },
                ),
              ],
            ),
            
            _MenuSection(
              title: '정보',
              items: [
                _MenuItem(
                  icon: Icons.info_outline,
                  title: '앱 정보',
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'IBank 그룹웨어',
                      applicationVersion: '1.0.0',
                      applicationLegalese: '© 2024 IBank',
                    );
                  },
                ),
                _MenuItem(
                  icon: Icons.privacy_tip_outlined,
                  title: '개인정보 처리방침',
                  onTap: () {
                    // TODO: Open privacy policy
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FilledButton.tonal(
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  backgroundColor: Colors.red.withOpacity(0.1),
                  foregroundColor: Colors.red,
                ),
                onPressed: () async {
                  final shouldLogout = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('로그아웃'),
                      content: const Text('정말 로그아웃 하시겠습니까?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('취소'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('로그아웃'),
                        ),
                      ],
                    ),
                  );

                  if (shouldLogout == true) {
                    final supabase = ref.read(supabaseClientProvider);
                    await supabase.auth.signOut();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  }
                },
                child: const Text('로그아웃'),
              ),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;

  const _MenuSection({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        ...items,
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
} 