import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:excel/excel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/providers/supabase_provider.dart';

class EmployeeRegistrationScreen extends ConsumerStatefulWidget {
  const EmployeeRegistrationScreen({super.key});

  @override
  ConsumerState<EmployeeRegistrationScreen> createState() => _EmployeeRegistrationScreenState();
}

class _EmployeeRegistrationScreenState extends ConsumerState<EmployeeRegistrationScreen> {
  bool _isLoading = false;
  String _statusMessage = '';
  int _totalEmployees = 0;
  int _processedEmployees = 0;
  int _successCount = 0;
  int _errorCount = 0;
  List<String> _errorMessages = [];

  Future<void> _importEmployees() async {
    setState(() {
      _isLoading = true;
      _statusMessage = '엑셀 파일을 읽는 중...';
      _errorMessages.clear();
      _totalEmployees = 0;
      _processedEmployees = 0;
      _successCount = 0;
      _errorCount = 0;
    });

    try {
      // Load Excel file from assets
      final ByteData data = await rootBundle.load('docs/임직원정보_20250712_151804.xlsx');
      final Uint8List bytes = data.buffer.asUint8List();
      
      final excel = Excel.decodeBytes(bytes);
      
      // Get the first sheet
      final sheet = excel.tables.keys.first;
      final table = excel.tables[sheet];
      
      if (table == null) {
        throw Exception('엑셀 파일을 읽을 수 없습니다.');
      }
      
      // Skip header row
      final rows = table.rows.skip(1).toList();
      _totalEmployees = rows.length;
      
      if (mounted) {
        setState(() {
          _statusMessage = '총 ${_totalEmployees}명의 임직원 정보를 발견했습니다.';
        });
      }
      
      final supabase = ref.read(supabaseClientProvider);
      
      // First, check if we need to add new columns to the users table
      await _addMissingColumns(supabase);
      
      // Process each employee
      for (final row in rows) {
        String name = '';
        String email = '';
        
        try {
          name = row[0]?.value?.toString() ?? '';
          final division = row[1]?.value?.toString() ?? '';
          final department = row[2]?.value?.toString() ?? '';
          final position = row[3]?.value?.toString() ?? '';
          final status = row[4]?.value?.toString() ?? '';
          final phone = row[5]?.value?.toString() ?? '';
          email = row[6]?.value?.toString() ?? '';
          final birthday = row[7]?.value?.toString() ?? '';
          final joindate = row[8]?.value?.toString() ?? '';
          final nateOn = row[9]?.value?.toString() ?? '';
          final facebook = row[10]?.value?.toString() ?? '';
          final twitter = row[11]?.value?.toString() ?? '';
          final avatarUrl = row[12]?.value?.toString() ?? '';
          
          if (email.isEmpty) {
            _errorMessages.add('이메일이 없는 직원: $name');
            _errorCount++;
            continue;
          }
          
          if (mounted) {
            setState(() {
              _statusMessage = '처리 중: $name ($email)';
              _processedEmployees++;
            });
          }
          
          // Add a small delay to avoid rate limiting
          await Future.delayed(const Duration(milliseconds: 500));
          
          // Create auth user
          try {
            // Option 1: Use regular signUp (recommended for client-side)
            final authResponse = await supabase.auth.signUp(
              email: email,
              password: '123456',
              data: {
                'name': name,
                'division': division,
                'department': department,
                'position': position,
                'status': status,
                'phone': phone,
                'birthday': birthday,
                'joindate': joindate,
                'avatar_url': avatarUrl,  // avatar_url 추가
              },
            );
            
            if (authResponse.user != null) {
              // Update user profile with additional fields
              await supabase.from('users').update({
                'name': name,
                'division': division,
                'department': department,
                'position': position,
                'status': status,
                'phone': phone,
                'birthday': birthday.isNotEmpty ? birthday : null,
                'joindate': joindate.isNotEmpty ? joindate : null,
                'avatar_url': avatarUrl.isNotEmpty ? avatarUrl : null,
              }).eq('id', authResponse.user!.id);
              
              _successCount++;
            } else {
              throw Exception('Failed to create user');
            }
            
            // Option 2: Use Edge Function (if you create one)
            // final response = await supabase.functions.invoke(
            //   'create-employee',
            //   body: {
            //     'email': email,
            //     'password': '123456',
            //     'userData': {
            //       'name': name,
            //       'division': division,
            //       'department': department,
            //       'position': position,
            //       'status': status,
            //       'phone': phone,
            //       'birthday': birthday,
            //       'joindate': joindate,
            //       'avatar_url': avatarUrl,
            //     },
            //   },
            // );
          } catch (e) {
            // User might already exist, try to update profile only
            final existingUser = await supabase
                .from('users')
                .select()
                .eq('email', email)
                .maybeSingle();
                
            if (existingUser != null) {
              await supabase.from('users').update({
                'name': name,
                'division': division,
                'department': department,
                'position': position,
                'status': status,
                'phone': phone,
                'birthday': birthday.isNotEmpty ? birthday : null,
                'joindate': joindate.isNotEmpty ? joindate : null,
                'avatar_url': avatarUrl.isNotEmpty ? avatarUrl : null,
              }).eq('email', email);
              
              _successCount++;
              _errorMessages.add('기존 사용자 업데이트: $name ($email)');
            } else {
              _errorCount++;
              _errorMessages.add('등록 실패: $name ($email) - ${e.toString()}');
            }
          }
        } catch (e) {
          _errorCount++;
          String errorMessage = e.toString();
          
          // Provide more user-friendly error messages
          if (errorMessage.contains('over_email_send_rate_limit')) {
            errorMessage = '이메일 전송 한도 초과 (잠시 후 다시 시도하세요)';
          } else if (errorMessage.contains('email rate limit')) {
            errorMessage = '이메일 전송 한도 초과';
          } else if (errorMessage.contains('User already registered')) {
            errorMessage = '이미 등록된 사용자';
          }
          
          _errorMessages.add('처리 오류 - $name ($email): $errorMessage');
        }
      }
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          _statusMessage = '완료! 성공: $_successCount명, 실패: $_errorCount명';
        });
      }
      
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _statusMessage = '오류 발생: ${e.toString()}';
        });
      }
    }
  }
  
  Future<void> _addMissingColumns(SupabaseClient supabase) async {
    try {
      // Add missing columns to users table
      await supabase.rpc('exec_sql', params: {
        'sql': '''
          ALTER TABLE public.users 
          ADD COLUMN IF NOT EXISTS division TEXT,
          ADD COLUMN IF NOT EXISTS status TEXT,
          ADD COLUMN IF NOT EXISTS birthday TEXT,
          ADD COLUMN IF NOT EXISTS joindate TEXT;
        '''
      });
    } catch (e) {
      // If exec_sql RPC doesn't exist, we'll need to add columns manually via migration
      print('Note: Could not add columns automatically. You may need to add them manually.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('임직원 등록'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '엑셀 파일 임포트',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'docs/임직원정보_20250712_151804.xlsx 파일의 데이터를 Supabase에 등록합니다.',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '모든 사용자의 초기 비밀번호는 "123456"으로 설정됩니다.',
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_totalEmployees > 0) ...[
                        LinearProgressIndicator(
                          value: _totalEmployees > 0 
                              ? _processedEmployees / _totalEmployees 
                              : 0,
                        ),
                        const SizedBox(height: 8),
                        Text('진행률: $_processedEmployees / $_totalEmployees'),
                      ],
                      const SizedBox(height: 16),
                      Text(
                        _statusMessage,
                        style: TextStyle(
                          color: _statusMessage.contains('오류') 
                              ? Colors.red 
                              : Colors.blue,
                        ),
                      ),
                      if (_successCount > 0 || _errorCount > 0) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Chip(
                              label: Text('성공: $_successCount'),
                              backgroundColor: Colors.green.shade100,
                            ),
                            const SizedBox(width: 8),
                            Chip(
                              label: Text('실패: $_errorCount'),
                              backgroundColor: Colors.red.shade100,
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _isLoading ? null : _importEmployees,
                icon: _isLoading 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.upload_file),
                label: Text(_isLoading ? '처리 중...' : '임직원 데이터 임포트'),
              ),
              const SizedBox(height: 16),
              if (_errorMessages.isNotEmpty) ...[
                const Text(
                  '처리 로그:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Card(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: _errorMessages.length,
                      itemBuilder: (context, index) {
                        final message = _errorMessages[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            '• $message',
                            style: TextStyle(
                              fontSize: 12,
                              color: message.contains('실패') || message.contains('오류')
                                  ? Colors.red
                                  : Colors.grey[700],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
} 