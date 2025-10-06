@echo off
REM Talkative Chat App - Windows Build Script

echo 🚀 Building Talkative Chat App for Windows...

REM Check if Flutter is installed
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Flutter is not installed or not in PATH
    pause
    exit /b 1
)

REM Clean previous builds
echo 🧹 Cleaning previous builds...
flutter clean
flutter pub get

REM Create output directory
if not exist "build_output" mkdir build_output
if not exist "build_output\windows" mkdir build_output\windows

REM Build for Windows
echo 🏗️ Building for Windows...
flutter build windows --release
if %errorlevel% neq 0 (
    echo ❌ Windows build failed
    pause
    exit /b 1
)

REM Copy build output
echo 📦 Copying build output...
xcopy /E /I "build\windows\x64\runner\Release\*" "build_output\windows\"

REM Build Web
echo 🌐 Building for Web...
flutter build web --release --web-renderer html
if %errorlevel% neq 0 (
    echo ❌ Web build failed
    pause
    exit /b 1
)

REM Copy web output
xcopy /E /I "build\web\*" "build_output\web\"

REM Build Android (if Android SDK is available)
where adb >nul 2>&1
if %errorlevel% equ 0 (
    echo 🤖 Building Android APK...
    flutter build apk --release --split-per-abi
    if %errorlevel% equ 0 (
        if not exist "build_output\android" mkdir build_output\android
        copy "build\app\outputs\flutter-apk\*.apk" "build_output\android\"
        
        echo 📱 Building Android App Bundle...
        flutter build appbundle --release
        if %errorlevel% equ 0 (
            copy "build\app\outputs\bundle\release\*.aab" "build_output\android\"
        )
    )
) else (
    echo ⚠️ Android SDK not found, skipping Android builds
)

echo ✅ Build completed successfully!
echo 📁 Output directory: build_output\
pause