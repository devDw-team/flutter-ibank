#!/bin/bash

# Run Flutter app with environment variables
echo "Starting Flutter app in development mode..."
flutter run --dart-define-from-file=.env 