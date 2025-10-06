#!/bin/bash

# Talkative Chat App - Development Setup Script
# This script helps you set up the development environment

echo "🚀 Setting up Talkative Chat App Development Environment..."

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first."
    exit 1
fi

echo "✅ Flutter detected"

# Check Flutter doctor
echo "📋 Running Flutter doctor..."
flutter doctor

# Install dependencies
echo "📦 Installing dependencies..."
flutter pub get

# Generate necessary files
echo "🔧 Generating necessary files..."
# Add any code generation commands here if needed

# Clean and get dependencies again
echo "🧹 Cleaning project..."
flutter clean
flutter pub get

# Run static analysis
echo "🔍 Running static analysis..."
flutter analyze

# Format code
echo "🎨 Formatting code..."
flutter format .

echo "✅ Development environment setup complete!"
echo ""
echo "🎯 Next steps:"
echo "1. Set up Firebase project and add configuration files"
echo "2. Add your assets to the assets/ directory"
echo "3. Configure your IDE/Editor"
echo "4. Run: flutter run"
echo ""
echo "📚 Useful commands:"
echo "  flutter run               - Run the app in debug mode"
echo "  flutter test              - Run all tests"
echo "  flutter build apk         - Build Android APK"
echo "  flutter build ios         - Build iOS app"
echo "  flutter analyze           - Run static analysis"
echo "  flutter format .          - Format all code"
echo ""
echo "🔥 Happy coding! Building the best chat app ever! 🚀"