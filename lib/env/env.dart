class Env {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://yqjrgmeunxumvwntyljr.supabase.co',
  );
  
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlxanJnbWV1bnh1bXZ3bnR5bGpyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTIyMjAzODQsImV4cCI6MjA2Nzc5NjM4NH0.UedTLsXUhbIf4vOOs1cfrAQQkErkD3iPmQ6nRSRwt3I',
  );
} 