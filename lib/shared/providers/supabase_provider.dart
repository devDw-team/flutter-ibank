import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/data/models/user_model.dart';

// Supabase Client Provider
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// Auth State Provider
final authStateProvider = StreamProvider<AuthState>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return supabase.auth.onAuthStateChange;
});

// Current User Provider
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.value?.session?.user;
});

// Is Authenticated Provider
final isAuthenticatedProvider = Provider<bool>((ref) {
  final currentUser = ref.watch(currentUserProvider);
  return currentUser != null;
});

// User Details Provider (includes role)
final userDetailsProvider = FutureProvider<UserModel?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  
  final supabase = ref.read(supabaseClientProvider);
  
  try {
    final data = await supabase
        .from('users')
        .select()
        .eq('id', user.id)
        .single();
    
    return UserModel.fromJson(data);
  } catch (e) {
    return null;
  }
}); 