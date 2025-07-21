import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../shared/providers/supabase_provider.dart';
import '../../../auth/data/models/user_model.dart';
import '../../data/models/project_model.dart';
import '../../data/repositories/project_repository.dart';

part 'project_provider.freezed.dart';

// Projects stream provider
final projectsStreamProvider = StreamProvider.autoDispose<List<ProjectModel>>((ref) {
  final repository = ref.watch(projectRepositoryProvider);
  return repository.streamProjects();
});

// Selected project provider
final selectedProjectProvider = StateProvider<String?>((ref) => null);

// Project detail provider
final projectDetailProvider = FutureProvider.autoDispose.family<ProjectModel, String>((ref, projectId) async {
  final repository = ref.watch(projectRepositoryProvider);
  return repository.getProjectById(projectId);
});

// Project filter provider
final projectFilterProvider = StateProvider<ProjectStatus?>((ref) => null);

// Filtered projects provider
final filteredProjectsProvider = Provider.autoDispose<List<ProjectModel>>((ref) {
  final projectsAsync = ref.watch(projectsStreamProvider);
  final filter = ref.watch(projectFilterProvider);
  
  return projectsAsync.when(
    data: (projects) {
      if (filter == null) return projects;
      return projects.where((project) => project.status == filter).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Project state
@freezed
class ProjectState with _$ProjectState {
  const factory ProjectState({
    @Default(false) bool isLoading,
    String? error,
  }) = _ProjectState;
}

// Project actions provider
final projectActionsProvider = Provider<ProjectActions>((ref) {
  return ProjectActions(ref);
});

class ProjectActions {
  final Ref _ref;

  ProjectActions(this._ref);

  ProjectRepository get _repository => _ref.read(projectRepositoryProvider);

  Future<ProjectModel> createProject(ProjectModel project, {Map<UserModel, ProjectMemberRole>? members}) async {
    try {
      final newProject = await _repository.createProject(project);
      
      // Add members if provided
      if (members != null && members.isNotEmpty) {
        for (final entry in members.entries) {
          try {
            await _repository.addProjectMember(
              projectId: newProject.id,
              userEmail: entry.key.email,
              role: entry.value,
            );
          } catch (e) {
            // Log error but continue adding other members
            print('Failed to add member ${entry.key.email}: $e');
          }
        }
      }
      
      // Refresh projects list
      _ref.invalidate(projectsStreamProvider);
      
      return newProject;
    } catch (e) {
      throw Exception('Failed to create project: $e');
    }
  }

  Future<ProjectModel> updateProject(ProjectModel project) async {
    try {
      final updatedProject = await _repository.updateProject(project);
      
      // Refresh projects list and project detail
      _ref.invalidate(projectsStreamProvider);
      _ref.invalidate(projectDetailProvider(project.id));
      
      return updatedProject;
    } catch (e) {
      throw Exception('Failed to update project: $e');
    }
  }

  Future<void> deleteProject(String projectId) async {
    try {
      await _repository.deleteProject(projectId);
      
      // Refresh projects list
      _ref.invalidate(projectsStreamProvider);
    } catch (e) {
      throw Exception('Failed to delete project: $e');
    }
  }

  Future<void> addMember({
    required String projectId,
    required String userEmail,
    required ProjectMemberRole role,
  }) async {
    try {
      await _repository.addProjectMember(
        projectId: projectId,
        userEmail: userEmail,
        role: role,
      );
      // Refresh project detail
      _ref.invalidate(projectDetailProvider(projectId));
    } catch (e) {
      throw Exception('Failed to add member: $e');
    }
  }

  Future<void> updateMemberRole({
    required String projectId,
    required String userId,
    required ProjectMemberRole newRole,
  }) async {
    try {
      await _repository.updateMemberRole(
        projectId: projectId,
        userId: userId,
        newRole: newRole,
      );
      // Refresh project detail
      _ref.invalidate(projectDetailProvider(projectId));
    } catch (e) {
      throw Exception('Failed to update member role: $e');
    }
  }

  Future<void> removeMember({
    required String projectId,
    required String userId,
  }) async {
    try {
      await _repository.removeMember(
        projectId: projectId,
        userId: userId,
      );
      // Refresh project detail
      _ref.invalidate(projectDetailProvider(projectId));
    } catch (e) {
      throw Exception('Failed to remove member: $e');
    }
  }

  void setSelectedProject(String? projectId) {
    _ref.read(selectedProjectProvider.notifier).state = projectId;
  }

  void setFilter(ProjectStatus? status) {
    _ref.read(projectFilterProvider.notifier).state = status;
  }
}

// User role in project provider
final userProjectRoleProvider = Provider.autoDispose.family<ProjectMemberRole?, String>((ref, projectId) {
  final projectAsync = ref.watch(projectDetailProvider(projectId));
  final currentUserId = ref.watch(currentUserIdProvider);
  
  return projectAsync.when(
    data: (project) {
      final member = project.members.firstWhere(
        (m) => m.userId == currentUserId,
        orElse: () => ProjectMemberModel(
          id: '',
          projectId: '',
          userId: '',
          role: ProjectMemberRole.viewer,
          joinedAt: DateTime.now(),
        ),
      );
      return member.role;
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

// Current user ID provider (from supabase auth)
final currentUserIdProvider = Provider<String?>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return supabase.auth.currentUser?.id;
});