#!/bin/bash

# Run build_runner for code generation
echo "Running code generation..."
flutter pub run build_runner build --delete-conflicting-outputs

echo "Code generation completed!" 