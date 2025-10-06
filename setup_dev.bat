@echo off
REM Talkative Chat App - Development Setup Script (Windows)
REM This script helps you set up the development environment

echo 🚀 Setting up Talkative Chat App Development Environment...

REM Check if Flutter is installed
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Flutter is not installed. Please install Flutter first.
    pause
    exit /b 1
)

echo ✅ Flutter detected

REM Check Flutter doctor
echo 📋 Running Flutter doctor...
flutter doctor

REM Install dependencies
echo 📦 Installing dependencies...
flutter pub get

REM Clean and get dependencies again
echo 🧹 Cleaning project...
flutter clean
flutter pub get

REM Run static analysis
echo 🔍 Running static analysis...
flutter analyze

REM Format code
echo 🎨 Formatting code...
flutter format .

echo ✅ Development environment setup complete!
echo.
echo 🎯 Next steps:
echo 1. Set up Firebase project and add configuration files
echo 2. Add your assets to the assets/ directory
echo 3. Configure your IDE/Editor
echo 4. Run: flutter run
echo.
echo 📚 Useful commands:
echo   flutter run               - Run the app in debug mode
echo   flutter test              - Run all tests
echo   flutter build apk         - Build Android APK
echo   flutter build ios         - Build iOS app
echo   flutter analyze           - Run static analysis
echo   flutter format .          - Format all code
echo.
echo 🔥 Happy coding! Building the best chat app ever! 🚀
pause