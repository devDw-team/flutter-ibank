import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../shared/providers/supabase_provider.dart';
import '../models/project_model.dart';

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return ProjectRepository(supabase);
});

class ProjectRepository {
  final SupabaseClient _supabase;

  ProjectRepository(this._supabase);

  // Get all projects (user is member of)
  Future<List<ProjectModel>> getProjects() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    // Directly query projects - RLS will filter to only projects user can see
    final projectsResponse = await _supabase
        .from('projects')
        .select('''
          *,
          users!owner_id (id, name, email, avatar_url)
        ''');

    return (projectsResponse as List).map((projectData) {
      final ownerData = projectData['users'] as Map<String, dynamic>?;
      
      return ProjectModel.fromJson({
        ...projectData,
        'ownerName': ownerData?['name'],
        'ownerEmail': ownerData?['email'],
      });
    }).toList();
  }

  // Get project by ID with members
  Future<ProjectModel> getProjectById(String projectId) async {
    final response = await _supabase
        .from('projects')
        .select('''
          *,
          users!owner_id (id, name, email, avatar_url),
          project_members (
            *,
            users!user_id (id, name, email, avatar_url)
          )
        ''')
        .eq('id', projectId)
        .single();

    final ownerData = response['users'] as Map<String, dynamic>?;
    final membersData = response['project_members'] as List<dynamic>? ?? [];

    final members = membersData.map((memberData) {
      final userData = memberData['users'] as Map<String, dynamic>?;
      return ProjectMemberModel.fromJson({
        ...memberData,
        'userName': userData?['name'],
        'userEmail': userData?['email'],
        'userAvatar': userData?['avatar_url'],
      });
    }).toList();

    return ProjectModel.fromJson({
      ...response,
      'ownerName': ownerData?['name'],
      'ownerEmail': ownerData?['email'],
      'members': members,
    });
  }

  // Create a new project
  Future<ProjectModel> createProject(ProjectModel project) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    // Start a transaction
    final projectData = {
      'name': project.name,
      'description': project.description,
      'status': project.status.name,
      'owner_id': userId,
      'start_date': project.startDate?.toIso8601String(),
      'end_date': project.endDate?.toIso8601String(),
    };

    // Create project
    final projectResponse = await _supabase
        .from('projects')
        .insert(projectData)
        .select()
        .single();

    // Add owner as a member
    await _supabase.from('project_members').insert({
      'project_id': projectResponse['id'],
      'user_id': userId,
      'role': ProjectMemberRole.owner.name,
    });

    return getProjectById(projectResponse['id']);
  }

  // Update project
  Future<ProjectModel> updateProject(ProjectModel project) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    // Check if user has permission
    final memberResponse = await _supabase
        .from('project_members')
        .select('role')
        .eq('project_id', project.id)
        .eq('user_id', userId)
        .single();

    final role = ProjectMemberRole.values.firstWhere(
      (r) => r.name == memberResponse['role'],
      orElse: () => ProjectMemberRole.viewer,
    );

    if (!role.canEdit) {
      throw Exception('You do not have permission to edit this project');
    }

    final data = {
      'name': project.name,
      'description': project.description,
      'status': project.status.name,
      'start_date': project.startDate?.toIso8601String(),
      'end_date': project.endDate?.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    await _supabase
        .from('projects')
        .update(data)
        .eq('id', project.id);

    return getProjectById(project.id);
  }

  // Delete project
  Future<void> deleteProject(String projectId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    // Check if user is owner
    final projectResponse = await _supabase
        .from('projects')
        .select('owner_id')
        .eq('id', projectId)
        .single();

    if (projectResponse['owner_id'] != userId) {
      throw Exception('Only the project owner can delete this project');
    }

    await _supabase.from('projects').delete().eq('id', projectId);
  }

  // Add member to project
  Future<void> addProjectMember({
    required String projectId,
    required String userEmail,
    required ProjectMemberRole role,
  }) async {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) throw Exception('User not authenticated');

    // Check if current user has permission
    final memberResponse = await _supabase
        .from('project_members')
        .select('role')
        .eq('project_id', projectId)
        .eq('user_id', currentUserId)
        .single();

    final currentRole = ProjectMemberRole.values.firstWhere(
      (r) => r.name == memberResponse['role'],
      orElse: () => ProjectMemberRole.viewer,
    );

    if (!currentRole.canManageMembers) {
      throw Exception('You do not have permission to manage members');
    }

    // Find user by email
    final userResponse = await _supabase
        .from('users')
        .select('id')
        .eq('email', userEmail)
        .single();

    // Add member
    await _supabase.from('project_members').insert({
      'project_id': projectId,
      'user_id': userResponse['id'],
      'role': role.name,
    });
  }

  // Update member role
  Future<void> updateMemberRole({
    required String projectId,
    required String userId,
    required ProjectMemberRole newRole,
  }) async {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) throw Exception('User not authenticated');

    // Check if current user has permission
    final memberResponse = await _supabase
        .from('project_members')
        .select('role')
        .eq('project_id', projectId)
        .eq('user_id', currentUserId)
        .single();

    final currentRole = ProjectMemberRole.values.firstWhere(
      (r) => r.name == memberResponse['role'],
      orElse: () => ProjectMemberRole.viewer,
    );

    if (!currentRole.canManageMembers) {
      throw Exception('You do not have permission to manage members');
    }

    await _supabase
        .from('project_members')
        .update({'role': newRole.name})
        .eq('project_id', projectId)
        .eq('user_id', userId);
  }

  // Remove member from project
  Future<void> removeMember({
    required String projectId,
    required String userId,
  }) async {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) throw Exception('User not authenticated');

    // Check if current user has permission
    final memberResponse = await _supabase
        .from('project_members')
        .select('role')
        .eq('project_id', projectId)
        .eq('user_id', currentUserId)
        .single();

    final currentRole = ProjectMemberRole.values.firstWhere(
      (r) => r.name == memberResponse['role'],
      orElse: () => ProjectMemberRole.viewer,
    );

    if (!currentRole.canManageMembers) {
      throw Exception('You do not have permission to manage members');
    }

    // Cannot remove owner
    final targetMemberResponse = await _supabase
        .from('project_members')
        .select('role')
        .eq('project_id', projectId)
        .eq('user_id', userId)
        .single();

    if (targetMemberResponse['role'] == ProjectMemberRole.owner.name) {
      throw Exception('Cannot remove project owner');
    }

    await _supabase
        .from('project_members')
        .delete()
        .eq('project_id', projectId)
        .eq('user_id', userId);
  }

  // Stream projects
  Stream<List<ProjectModel>> streamProjects() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Stream.error('User not authenticated');

    // Stream projects directly - RLS will handle filtering
    return _supabase
        .from('projects')
        .stream(primaryKey: ['id'])
        .asyncMap((data) async {
          if (data.isEmpty) return <ProjectModel>[];
          
          // Get project IDs to fetch owner information
          final projectIds = data.map((p) => p['id'] as String).toList();
          
          // Fetch projects with owner information
          final projectsWithOwners = await _supabase
              .from('projects')
              .select('''
                *,
                users!owner_id (id, name, email, avatar_url)
              ''')
              .inFilter('id', projectIds);
          
          return (projectsWithOwners as List).map((projectData) {
            final ownerData = projectData['users'] as Map<String, dynamic>?;
            
            return ProjectModel.fromJson({
              ...projectData,
              'ownerName': ownerData?['name'],
              'ownerEmail': ownerData?['email'],
            });
          }).toList();
        });
  }
}