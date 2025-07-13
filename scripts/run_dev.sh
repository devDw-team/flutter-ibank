#!/bin/bash

# Development run script with Supabase configuration

# Set your Supabase credentials here or load from .env file
SUPABASE_URL="https://yqjrgmeunxumvwntyljr.supabase.co"
SUPABASE_ANON_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlxanJnbWV1bnh1bXZ3bnR5bGpyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTIyMjAzODQsImV4cCI6MjA2Nzc5NjM4NH0.UedTLsXUhbIf4vOOs1cfrAQQkErkD3iPmQ6nRSRwt3I"

# Run Flutter with environment variables
flutter run \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY 