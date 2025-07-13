import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/supabase_provider.dart';

// Admin permission check provider
final isAdminProvider = Provider<bool>((ref) {
  final userDetailsAsync = ref.watch(userDetailsProvider);
  
  return userDetailsAsync.when(
    data: (userDetails) => userDetails?.role == 'admin',
    loading: () => false,
    error: (_, __) => false,
  );
});

// Admin permission async provider 
final adminPermissionProvider = FutureProvider<bool>((ref) async {
  final userDetails = await ref.watch(userDetailsProvider.future);
  return userDetails?.role == 'admin' ?? false;
}); 