import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/providers/supabase_provider.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../employees/presentation/screens/employee_list_screen.dart';
import '../../data/models/project_model.dart';

// Search query provider
final memberSearchQueryProvider = StateProvider<String>((ref) => '');

// Selected temporary members provider
final tempSelectedMembersProvider = StateProvider<Map<UserModel, ProjectMemberRole>>((ref) => {});

// Filtered users provider
final filteredUsersProvider = Provider.autoDispose<List<UserModel>>((ref) {
  final usersAsync = ref.watch(employeesListProvider);
  final searchQuery = ref.watch(memberSearchQueryProvider).toLowerCase();
  final currentUserId = ref.read(supabaseClientProvider).auth.currentUser?.id;
  final existingMembers = ref.watch(tempSelectedMembersProvider);
  
  return usersAsync.when(
    data: (users) {
      var filteredUsers = users.where((user) {
        // Filter out current user
        if (user.id == currentUserId) return false;
        
        // Filter out already selected members
        if (existingMembers.containsKey(user)) return false;
        
        // Apply search filter
        if (searchQuery.isEmpty) return true;
        
        final name = (user.name ?? '').toLowerCase();
        final email = user.email.toLowerCase();
        final department = (user.department ?? '').toLowerCase();
        final division = (user.division ?? '').toLowerCase();
        
        return name.contains(searchQuery) ||
            email.contains(searchQuery) ||
            department.contains(searchQuery) ||
            division.contains(searchQuery);
      }).toList();
      
      // Sort by name
      filteredUsers.sort((a, b) => 
        (a.name ?? '').compareTo(b.name ?? ''));
      
      return filteredUsers;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

class MemberSelectionDialog extends ConsumerStatefulWidget {
  final Map<UserModel, ProjectMemberRole> selectedMembers;
  final Function(Map<UserModel, ProjectMemberRole>) onMembersSelected;

  const MemberSelectionDialog({
    super.key,
    required this.selectedMembers,
    required this.onMembersSelected,
  });

  @override
  ConsumerState<MemberSelectionDialog> createState() => _MemberSelectionDialogState();
}

class _MemberSelectionDialogState extends ConsumerState<MemberSelectionDialog> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Initialize temp selected members with existing members
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(tempSelectedMembersProvider.notifier).state = 
          Map.from(widget.selectedMembers);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredUsers = ref.watch(filteredUsersProvider);
    final tempSelectedMembers = ref.watch(tempSelectedMembersProvider);
    final isLoading = ref.watch(employeesListProvider).isLoading;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 600,
          maxHeight: 700,
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.people_outline, color: AppColors.primary),
                      const SizedBox(width: 12),
                      const Text(
                        '프로젝트 참여자 선택',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          // Clear providers
                          ref.read(memberSearchQueryProvider.notifier).state = '';
                          ref.read(tempSelectedMembersProvider.notifier).state = {};
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Search bar
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: '이름, 이메일, 부서로 검색',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onChanged: (value) {
                      ref.read(memberSearchQueryProvider.notifier).state = value;
                    },
                  ),
                ],
              ),
            ),
            
            // Selected members count
            if (tempSelectedMembers.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                color: Theme.of(context).colorScheme.surfaceVariant.withValues(alpha: 0.3),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${tempSelectedMembers.length}명 선택됨',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: tempSelectedMembers.entries.map((entry) {
                            final user = entry.key;
                            return Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Theme.of(context).dividerColor),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    user.name ?? 'Unknown',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  const SizedBox(width: 4),
                                  InkWell(
                                    onTap: () {
                                      ref.read(tempSelectedMembersProvider.notifier)
                                          .update((state) {
                                        final newState = Map<UserModel, ProjectMemberRole>.from(state);
                                        newState.remove(user);
                                        return newState;
                                      });
                                    },
                                    child: Icon(
                                      Icons.close,
                                      size: 14,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            
            // User list
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredUsers.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _searchController.text.isEmpty
                                    ? '추가 가능한 사용자가 없습니다.'
                                    : '검색 결과가 없습니다.',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          itemCount: filteredUsers.length,
                          itemBuilder: (context, index) {
                            final user = filteredUsers[index];
                            final isSelected = tempSelectedMembers.containsKey(user);
                            
                            return ListTile(
                              leading: Stack(
                                children: [
                                  CircleAvatar(
                                    backgroundImage: user.avatarUrl != null
                                        ? NetworkImage(user.avatarUrl!)
                                        : null,
                                    child: user.avatarUrl == null
                                        ? Text(
                                            (user.name?.isNotEmpty ?? false)
                                                ? user.name![0].toUpperCase()
                                                : '?',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        : null,
                                  ),
                                  if (isSelected)
                                    Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.check,
                                          size: 12,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              title: Text(user.name ?? 'Unknown'),
                              subtitle: Text(
                                '${user.email}${user.department != null ? ' · ${user.department}' : ''}',
                              ),
                              trailing: isSelected
                                  ? IconButton(
                                      icon: const Icon(
                                        Icons.remove_circle,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        ref.read(tempSelectedMembersProvider.notifier)
                                            .update((state) {
                                          final newState = Map<UserModel, ProjectMemberRole>.from(state);
                                          newState.remove(user);
                                          return newState;
                                        });
                                      },
                                    )
                                  : IconButton(
                                      icon: const Icon(
                                        Icons.add_circle_outline,
                                        color: Colors.green,
                                      ),
                                      onPressed: () {
                                        ref.read(tempSelectedMembersProvider.notifier)
                                            .update((state) {
                                          final newState = Map<UserModel, ProjectMemberRole>.from(state);
                                          newState[user] = ProjectMemberRole.member;
                                          return newState;
                                        });
                                      },
                                    ),
                              onTap: () {
                                if (isSelected) {
                                  ref.read(tempSelectedMembersProvider.notifier)
                                      .update((state) {
                                    final newState = Map<UserModel, ProjectMemberRole>.from(state);
                                    newState.remove(user);
                                    return newState;
                                  });
                                } else {
                                  ref.read(tempSelectedMembersProvider.notifier)
                                      .update((state) {
                                    final newState = Map<UserModel, ProjectMemberRole>.from(state);
                                    newState[user] = ProjectMemberRole.member;
                                    return newState;
                                  });
                                }
                              },
                            );
                          },
                        ),
            ),
            
            // Action buttons
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      // Clear providers
                      ref.read(memberSearchQueryProvider.notifier).state = '';
                      ref.read(tempSelectedMembersProvider.notifier).state = {};
                      Navigator.pop(context);
                    },
                    child: const Text('취소'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: tempSelectedMembers.isEmpty
                        ? null
                        : () {
                            // Get only newly added members
                            final newMembers = Map<UserModel, ProjectMemberRole>.from(
                              tempSelectedMembers
                            );
                            
                            // Remove already existing members
                            widget.selectedMembers.keys.forEach((user) {
                              newMembers.remove(user);
                            });
                            
                            widget.onMembersSelected(newMembers);
                            
                            // Clear providers
                            ref.read(memberSearchQueryProvider.notifier).state = '';
                            ref.read(tempSelectedMembersProvider.notifier).state = {};
                            
                            Navigator.pop(context);
                          },
                    child: Text(
                      tempSelectedMembers.isEmpty
                          ? '선택하기'
                          : '${tempSelectedMembers.length}명 추가',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

