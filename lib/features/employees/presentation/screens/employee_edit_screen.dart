import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../features/auth/data/models/user_model.dart';
import '../../../../shared/providers/supabase_provider.dart';

// Employee Provider
final employeeProvider = FutureProvider.family<UserModel?, String>((ref, userId) async {
  final supabase = ref.read(supabaseClientProvider);
  
  try {
    final data = await supabase
        .from('users')
        .select()
        .eq('id', userId)
        .single();
    
    return UserModel.fromJson(data);
  } catch (e) {
    throw Exception('Failed to load employee: $e');
  }
});

class EmployeeEditScreen extends ConsumerStatefulWidget {
  final String employeeId;

  const EmployeeEditScreen({
    super.key,
    required this.employeeId,
  });

  @override
  ConsumerState<EmployeeEditScreen> createState() => _EmployeeEditScreenState();
}

class _EmployeeEditScreenState extends ConsumerState<EmployeeEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _divisionController = TextEditingController();
  final _departmentController = TextEditingController();
  final _positionController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _joinDateController = TextEditingController();

  bool _isLoading = false;
  XFile? _selectedImage;
  String? _currentAvatarUrl;
  DateTime? _birthDate;
  DateTime? _joinDate;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _divisionController.dispose();
    _departmentController.dispose();
    _positionController.dispose();
    _birthDateController.dispose();
    _joinDateController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  Future<void> _selectDate(BuildContext context, bool isBirthDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isBirthDate ? _birthDate ?? DateTime.now() : _joinDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('ko', 'KR'),
    );
    
    if (picked != null) {
      setState(() {
        if (isBirthDate) {
          _birthDate = picked;
          _birthDateController.text = DateFormat('yyyy-MM-dd').format(picked);
        } else {
          _joinDate = picked;
          _joinDateController.text = DateFormat('yyyy-MM-dd').format(picked);
        }
      });
    }
  }

  Future<String?> _uploadAvatar(String userId) async {
    if (_selectedImage == null) return _currentAvatarUrl;

    final supabase = ref.read(supabaseClientProvider);
    final file = File(_selectedImage!.path);
    final fileExt = _selectedImage!.path.split('.').last;
    final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
    final filePath = 'avatars/$fileName';

    try {
      // Upload new avatar
      await supabase.storage
          .from('avatars')
          .upload(filePath, file);

      // Get public URL
      final imageUrl = supabase.storage
          .from('avatars')
          .getPublicUrl(filePath);

      // Delete old avatar if exists
      if (_currentAvatarUrl != null) {
        final oldPath = _currentAvatarUrl!.split('/').last;
        await supabase.storage
            .from('avatars')
            .remove(['avatars/$oldPath']);
      }

      return imageUrl;
    } catch (e) {
      throw Exception('Failed to upload avatar: $e');
    }
  }

  Future<void> _updateEmployee() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final supabase = ref.read(supabaseClientProvider);
      
      // Upload avatar if changed
      String? avatarUrl = await _uploadAvatar(widget.employeeId);

      // Update user data
      await supabase
          .from('users')
          .update({
            'name': _nameController.text.trim(),
            'phone': _phoneController.text.trim(),
            'division': _divisionController.text.trim(),
            'department': _departmentController.text.trim(),
            'position': _positionController.text.trim(),
            'birthday': _birthDate?.toIso8601String(),
            'joindate': _joinDate?.toIso8601String(),
            'avatar_url': avatarUrl,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', widget.employeeId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('임직원 정보가 수정되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final employeeAsync = ref.watch(employeeProvider(widget.employeeId));
    final currentUserAsync = ref.watch(userDetailsProvider);
    final currentUser = currentUserAsync.valueOrNull;
    
    // Check permission
    final isAdmin = currentUser?.role == 'admin';
    final isOwnProfile = currentUser?.id == widget.employeeId;
    
    if (!isAdmin && !isOwnProfile) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('권한 없음'),
        ),
        body: const Center(
          child: Text('이 페이지에 접근할 권한이 없습니다.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('임직원 정보 수정'),
      ),
      body: employeeAsync.when(
        data: (employee) {
          if (employee == null) {
            return const Center(
              child: Text('임직원 정보를 찾을 수 없습니다.'),
            );
          }

          // Initialize controllers on first load
          if (_emailController.text.isEmpty) {
            _emailController.text = employee.email;
            _nameController.text = employee.name ?? '';
            _phoneController.text = employee.phone ?? '';
            _divisionController.text = employee.division ?? '';
            _departmentController.text = employee.department ?? '';
            _positionController.text = employee.position ?? '';
            _currentAvatarUrl = employee.avatarUrl;
            
            if (employee.birthday != null) {
              _birthDate = DateTime.parse(employee.birthday!);
              _birthDateController.text = DateFormat('yyyy-MM-dd').format(_birthDate!);
            }
            
            if (employee.joindate != null) {
              _joinDate = DateTime.parse(employee.joindate!);
              _joinDateController.text = DateFormat('yyyy-MM-dd').format(_joinDate!);
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar Section
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: AppColors.primary,
                          backgroundImage: _selectedImage != null
                              ? FileImage(File(_selectedImage!.path))
                              : (_currentAvatarUrl != null
                                  ? NetworkImage(_currentAvatarUrl!) as ImageProvider
                                  : null),
                          child: (_selectedImage == null && _currentAvatarUrl == null)
                              ? Text(
                                  employee.name?.substring(0, 1).toUpperCase() ?? 
                                  employee.email.substring(0, 1).toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            backgroundColor: AppColors.primary,
                            child: IconButton(
                              icon: const Icon(Icons.camera_alt, color: Colors.white),
                              onPressed: _pickImage,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Email (Read-only)
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: '이메일',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    enabled: false,
                  ),
                  const SizedBox(height: 16),

                  // Name
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: '이름 *',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '이름을 입력해주세요';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Phone
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: '전화번호',
                      prefixIcon: Icon(Icons.phone),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),

                  // Division
                  TextFormField(
                    controller: _divisionController,
                    decoration: const InputDecoration(
                      labelText: '소속',
                      prefixIcon: Icon(Icons.domain),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Department
                  TextFormField(
                    controller: _departmentController,
                    decoration: const InputDecoration(
                      labelText: '부서',
                      prefixIcon: Icon(Icons.business),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Position
                  TextFormField(
                    controller: _positionController,
                    decoration: const InputDecoration(
                      labelText: '직급',
                      prefixIcon: Icon(Icons.badge),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Birth Date
                  TextFormField(
                    controller: _birthDateController,
                    decoration: const InputDecoration(
                      labelText: '생년월일',
                      prefixIcon: Icon(Icons.cake),
                      suffixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                    onTap: () => _selectDate(context, true),
                  ),
                  const SizedBox(height: 16),

                  // Join Date
                  TextFormField(
                    controller: _joinDateController,
                    decoration: const InputDecoration(
                      labelText: '입사일',
                      prefixIcon: Icon(Icons.work),
                      suffixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                    onTap: () => _selectDate(context, false),
                  ),
                  const SizedBox(height: 32),

                  // Update Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed: _isLoading ? null : _updateEmployee,
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('정보 수정'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Text('오류: $error'),
        ),
      ),
    );
  }
}