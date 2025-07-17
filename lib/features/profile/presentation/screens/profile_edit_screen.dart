import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/utils/validators.dart';
import '../../../../shared/providers/supabase_provider.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _divisionController = TextEditingController();
  final _departmentController = TextEditingController();
  final _positionController = TextEditingController();
  final _birthdayController = TextEditingController();
  final _joindateController = TextEditingController();
  
  XFile? _imageFile;
  String? _currentAvatarUrl;
  bool _isLoading = false;
  bool _isInitialized = false;
  final _picker = ImagePicker();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _loadUserData();
      _isInitialized = true;
    }
  }

  Future<void> _loadUserData() async {
    final userDetailsAsync = ref.read(userDetailsProvider);
    userDetailsAsync.whenData((userDetails) {
      if (userDetails != null) {
        setState(() {
          _nameController.text = userDetails.name ?? '';
          _phoneController.text = userDetails.phone ?? '';
          _divisionController.text = userDetails.division ?? '';
          _departmentController.text = userDetails.department ?? '';
          _positionController.text = userDetails.position ?? '';
          _birthdayController.text = userDetails.birthday ?? '';
          _joindateController.text = userDetails.joindate ?? '';
          _currentAvatarUrl = userDetails.avatarUrl;
        });
      }
    });
  }

  @override
  void dispose() {
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
    if (_imageFile == null) return _currentAvatarUrl;

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
      return _currentAvatarUrl;
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final supabase = ref.read(supabaseClientProvider);
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('사용자 정보를 찾을 수 없습니다.');

      // Upload avatar if changed
      String? avatarUrl;
      if (_imageFile != null) {
        avatarUrl = await _uploadImage(user.id);
      } else {
        avatarUrl = _currentAvatarUrl;
      }

      // Update user profile
      await supabase.from('users').update({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'division': _divisionController.text.trim(),
        'department': _departmentController.text.trim(),
        'position': _positionController.text.trim(),
        'birthday': _birthdayController.text.isEmpty ? null : _birthdayController.text,
        'joindate': _joindateController.text.isEmpty ? null : _joindateController.text,
        'avatar_url': avatarUrl,
      }).eq('id', user.id);

      if (mounted) {
        // Refresh the user details provider
        ref.invalidate(userDetailsProvider);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('프로필이 업데이트되었습니다.')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('업데이트 실패: $e')),
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
        title: const Text('프로필 편집'),
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
                        : _currentAvatarUrl != null
                            ? NetworkImage(_currentAvatarUrl!)
                            : null,
                    child: (_imageFile == null && _currentAvatarUrl == null)
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
                  child: const Text('프로필 사진 변경'),
                ),
              ),
              const SizedBox(height: 24),

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
                onPressed: _isLoading ? null : _updateProfile,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('저장'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}