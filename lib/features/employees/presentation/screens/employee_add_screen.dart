import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/utils/validators.dart';
import '../../../../shared/providers/supabase_provider.dart';

class EmployeeAddScreen extends ConsumerStatefulWidget {
  const EmployeeAddScreen({super.key});

  @override
  ConsumerState<EmployeeAddScreen> createState() => _EmployeeAddScreenState();
}

class _EmployeeAddScreenState extends ConsumerState<EmployeeAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _divisionController = TextEditingController();
  final _departmentController = TextEditingController();
  final _positionController = TextEditingController();
  final _birthdayController = TextEditingController();
  final _joindateController = TextEditingController();
  
  XFile? _imageFile;
  bool _isLoading = false;
  final _picker = ImagePicker();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _divisionController.dispose();
    _departmentController.dispose();
    _positionController.dispose();
    _birthdayController.dispose();
    _joindateController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _imageFile = image;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이미지 선택 실패: $e')),
        );
      }
    }
  }

  Future<String?> _uploadImage(String userId) async {
    if (_imageFile == null) return null;

    try {
      final supabase = ref.read(supabaseClientProvider);
      final bytes = await _imageFile!.readAsBytes();
      final fileExt = _imageFile!.path.split('.').last;
      final fileName = '$userId.$fileExt';
      final filePath = 'avatars/$fileName';

      await supabase.storage.from('avatars').uploadBinary(
        filePath,
        bytes,
        fileOptions: FileOptions(
          cacheControl: '3600',
          upsert: true,
        ),
      );

      final String imageUrl = supabase.storage
          .from('avatars')
          .getPublicUrl(filePath);

      return imageUrl;
    } catch (e) {
      debugPrint('Image upload error: $e');
      return null;
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final supabase = ref.read(supabaseClientProvider);

      // 1. Create auth user
      final AuthResponse authResponse = await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (authResponse.user == null) {
        throw Exception('사용자 생성 실패');
      }

      final userId = authResponse.user!.id;

      // 2. Upload avatar if exists
      String? avatarUrl;
      if (_imageFile != null) {
        avatarUrl = await _uploadImage(userId);
      }

      // 3. Update user profile
      await supabase.from('users').update({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'division': _divisionController.text.trim(),
        'department': _departmentController.text.trim(),
        'position': _positionController.text.trim(),
        'birthday': _birthdayController.text.trim(),
        'joindate': _joindateController.text.trim(),
        'avatar_url': avatarUrl,
      }).eq('id', userId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('임직원 등록이 완료되었습니다.')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('등록 실패: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('ko', 'KR'),
    );
    if (picked != null) {
      controller.text = picked.toString().split(' ')[0];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('임직원 등록'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile Image
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _imageFile != null
                        ? (kIsWeb
                            ? NetworkImage(_imageFile!.path)
                            : FileImage(File(_imageFile!.path)))
                            as ImageProvider
                        : null,
                    child: _imageFile == null
                        ? const Icon(
                            Icons.camera_alt,
                            size: 40,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: _pickImage,
                  child: const Text('프로필 사진 선택'),
                ),
              ),
              const SizedBox(height: 24),
              
              // Email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: '이메일 *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: Validators.email,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),

              // Password
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: '비밀번호 *',
                  border: OutlineInputBorder(),
                  helperText: '최소 6자 이상',
                ),
                obscureText: true,
                validator: Validators.password,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),

              // Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '이름 *',
                  border: OutlineInputBorder(),
                ),
                validator: Validators.required,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),

              // Phone
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: '휴대전화',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),

              // Division
              TextFormField(
                controller: _divisionController,
                decoration: const InputDecoration(
                  labelText: '소속',
                  border: OutlineInputBorder(),
                ),
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),

              // Department
              TextFormField(
                controller: _departmentController,
                decoration: const InputDecoration(
                  labelText: '부서',
                  border: OutlineInputBorder(),
                ),
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),

              // Position
              TextFormField(
                controller: _positionController,
                decoration: const InputDecoration(
                  labelText: '직급',
                  border: OutlineInputBorder(),
                ),
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),

              // Birthday
              TextFormField(
                controller: _birthdayController,
                decoration: const InputDecoration(
                  labelText: '생년월일',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () => _selectDate(_birthdayController),
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),

              // Join Date
              TextFormField(
                controller: _joindateController,
                decoration: const InputDecoration(
                  labelText: '입사일',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () => _selectDate(_joindateController),
                enabled: !_isLoading,
              ),
              const SizedBox(height: 24),

              // Submit Button
              FilledButton(
                onPressed: _isLoading ? null : _register,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('등록'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 