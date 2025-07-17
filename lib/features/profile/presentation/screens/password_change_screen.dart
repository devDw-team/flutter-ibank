import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/utils/validators.dart';
import '../../../../shared/providers/supabase_provider.dart';
import '../../../../env/env.dart';

class PasswordChangeScreen extends ConsumerStatefulWidget {
  const PasswordChangeScreen({super.key});

  @override
  ConsumerState<PasswordChangeScreen> createState() => _PasswordChangeScreenState();
}

class _PasswordChangeScreenState extends ConsumerState<PasswordChangeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _isCurrentPasswordVerified = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _verifyCurrentPassword() async {
    if (_currentPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('현재 비밀번호를 입력해주세요.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final supabase = ref.read(supabaseClientProvider);
      final user = supabase.auth.currentUser;
      
      if (user == null) {
        throw Exception('사용자 정보를 찾을 수 없습니다.');
      }

      // Create a separate Supabase client instance for password verification
      final tempSupabase = SupabaseClient(
        Env.supabaseUrl,
        Env.supabaseAnonKey,
        authOptions: const AuthClientOptions(
          autoRefreshToken: false,
        ),
      );
      
      try {
        // Verify current password using temporary client
        final response = await tempSupabase.auth.signInWithPassword(
          email: user.email!,
          password: _currentPasswordController.text,
        );

        if (response.user != null) {
          // Password is correct, proceed to password change
          setState(() {
            _isCurrentPasswordVerified = true;
          });
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('현재 비밀번호가 확인되었습니다.'),
                backgroundColor: Colors.green,
              ),
            );
          }
          
          // Sign out from temporary client
          await tempSupabase.auth.signOut();
        }
      } finally {
        // Dispose temporary client
        await tempSupabase.dispose();
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message == 'Invalid login credentials' 
              ? '현재 비밀번호가 올바르지 않습니다.' 
              : '오류: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
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
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('새 비밀번호가 일치하지 않습니다.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final supabase = ref.read(supabaseClientProvider);
      
      // Update password
      await supabase.auth.updateUser(
        UserAttributes(
          password: _newPasswordController.text,
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('비밀번호가 성공적으로 변경되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('비밀번호 변경 실패: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
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
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('비밀번호 변경'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Step indicator
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    _buildStepIndicator(
                      '1',
                      '현재 비밀번호 확인',
                      true,
                      _isCurrentPasswordVerified,
                    ),
                    Expanded(
                      child: Container(
                        height: 2,
                        color: _isCurrentPasswordVerified
                            ? Theme.of(context).primaryColor
                            : Colors.grey[300],
                      ),
                    ),
                    _buildStepIndicator(
                      '2',
                      '새 비밀번호 설정',
                      _isCurrentPasswordVerified,
                      false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              if (!_isCurrentPasswordVerified) ...[
                // Current password verification
                Text(
                  '현재 비밀번호 확인',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  '보안을 위해 현재 비밀번호를 먼저 확인해주세요.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                
                TextFormField(
                  controller: _currentPasswordController,
                  obscureText: _obscureCurrentPassword,
                  decoration: InputDecoration(
                    labelText: '현재 비밀번호',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureCurrentPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureCurrentPassword = !_obscureCurrentPassword;
                        });
                      },
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 24),
                
                FilledButton(
                  onPressed: _isLoading ? null : _verifyCurrentPassword,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('확인'),
                ),
              ] else ...[
                // New password form
                Text(
                  '새 비밀번호 설정',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  '안전한 비밀번호를 설정해주세요.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                
                // New password
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: _obscureNewPassword,
                  decoration: InputDecoration(
                    labelText: '새 비밀번호',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureNewPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureNewPassword = !_obscureNewPassword;
                        });
                      },
                    ),
                    border: const OutlineInputBorder(),
                    helperText: '최소 6자 이상',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '새 비밀번호를 입력해주세요.';
                    }
                    if (value.length < 6) {
                      return '비밀번호는 최소 6자 이상이어야 합니다.';
                    }
                    if (value == _currentPasswordController.text) {
                      return '현재 비밀번호와 동일한 비밀번호는 사용할 수 없습니다.';
                    }
                    return null;
                  },
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 16),
                
                // Confirm password
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: '새 비밀번호 확인',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '비밀번호 확인을 입력해주세요.';
                    }
                    if (value != _newPasswordController.text) {
                      return '비밀번호가 일치하지 않습니다.';
                    }
                    return null;
                  },
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 32),
                
                // Password requirements
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, size: 20, color: Colors.blue[700]),
                          const SizedBox(width: 8),
                          Text(
                            '안전한 비밀번호 만들기',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildPasswordRequirement('최소 6자 이상'),
                      _buildPasswordRequirement('영문, 숫자, 특수문자 조합 권장'),
                      _buildPasswordRequirement('개인정보 포함 금지'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : () {
                          setState(() {
                            _isCurrentPasswordVerified = false;
                            _newPasswordController.clear();
                            _confirmPasswordController.clear();
                          });
                        },
                        child: const Text('이전'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FilledButton(
                        onPressed: _isLoading ? null : _changePassword,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text('변경'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(String number, String label, bool isActive, bool isCompleted) {
    final color = isCompleted 
        ? Colors.green 
        : isActive 
            ? Theme.of(context).primaryColor 
            : Colors.grey[400];
    
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isCompleted || isActive ? color : Colors.transparent,
            border: Border.all(color: color!, width: 2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : Text(
                    number,
                    style: TextStyle(
                      color: isActive ? Colors.white : color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? Colors.black : Colors.grey[600],
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordRequirement(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 28, top: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, size: 16, color: Colors.blue[600]),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(color: Colors.blue[700], fontSize: 14),
          ),
        ],
      ),
    );
  }
}