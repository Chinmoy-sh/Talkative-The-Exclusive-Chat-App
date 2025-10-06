#!/bin/bash

# Talkative Chat App - Cross-Platform Build Script
# This script builds the app for all supported platforms

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
APP_VERSION=$(grep "version:" pubspec.yaml | cut -d " " -f 2)
BUILD_NUMBER=$(date +%s)
OUTPUT_DIR="build_output"

echo -e "${BLUE}🚀 Talkative Chat App - Multi-Platform Build${NC}"
echo -e "${BLUE}Version: $APP_VERSION${NC}"
echo -e "${BLUE}Build Number: $BUILD_NUMBER${NC}"
echo ""

# Function to print step
print_step() {
    echo -e "${YELLOW}▶ $1${NC}"
}

# Function to print success
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# Function to print error
print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Clean previous builds
print_step "Cleaning previous builds..."
flutter clean
flutter pub get
mkdir -p $OUTPUT_DIR
print_success "Clean completed"

# Build Web
print_step "Building for Web..."
if flutter build web --release --web-renderer html; then
    cp -r build/web $OUTPUT_DIR/
    print_success "Web build completed"
else
    print_error "Web build failed"
    exit 1
fi

# Build Android APK
if command -v android-sdk >/dev/null 2>&1 || [ -n "$ANDROID_HOME" ]; then
    print_step "Building Android APK..."
    if flutter build apk --release --split-per-abi; then
        mkdir -p $OUTPUT_DIR/android
        cp build/app/outputs/flutter-apk/*.apk $OUTPUT_DIR/android/
        print_success "Android APK build completed"
    else
        print_error "Android APK build failed"
    fi

    print_step "Building Android App Bundle..."
    if flutter build appbundle --release; then
        cp build/app/outputs/bundle/release/*.aab $OUTPUT_DIR/android/
        print_success "Android App Bundle build completed"
    else
        print_error "Android App Bundle build failed"
    fi
else
    print_error "Android SDK not found, skipping Android builds"
fi

# Build macOS (if on macOS)
if [[ "$OSTYPE" == "darwin"* ]]; then
    print_step "Building for macOS..."
    if flutter build macos --release; then
        mkdir -p $OUTPUT_DIR/macos
        cp -r build/macos/Build/Products/Release/talkative.app $OUTPUT_DIR/macos/
        print_success "macOS build completed"
    else
        print_error "macOS build failed"
    fi

    # Build iOS (requires Xcode)
    if command -v xcodebuild >/dev/null 2>&1; then
        print_step "Building for iOS..."
        if flutter build ios --release --no-codesign; then
            mkdir -p $OUTPUT_DIR/ios
            cp -r build/ios/iphoneos/Runner.app $OUTPUT_DIR/ios/
            print_success "iOS build completed"
        else
            print_error "iOS build failed"
        fi
    else
        print_error "Xcode not found, skipping iOS build"
    fi
fi

# Build Linux (if on Linux)
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    print_step "Building for Linux..."
    if flutter build linux --release; then
        mkdir -p $OUTPUT_DIR/linux
        cp -r build/linux/x64/release/bundle/* $OUTPUT_DIR/linux/
        print_success "Linux build completed"
    else
        print_error "Linux build failed"
    fi
fi

# Build Windows (if on Windows or with Wine)
if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]] || command -v wine >/dev/null 2>&1; then
    print_step "Building for Windows..."
    if flutter build windows --release; then
        mkdir -p $OUTPUT_DIR/windows
        cp -r build/windows/x64/runner/Release/* $OUTPUT_DIR/windows/
        print_success "Windows build completed"
    else
        print_error "Windows build failed"
    fi
fi

# Create archive
print_step "Creating release archive..."
cd $OUTPUT_DIR
tar -czf "talkative-${APP_VERSION}-${BUILD_NUMBER}.tar.gz" *
cd ..

print_success "All builds completed successfully!"
echo -e "${GREEN}📦 Output directory: $OUTPUT_DIR${NC}"
echo -e "${GREEN}🗜️  Archive: $OUTPUT_DIR/talkative-${APP_VERSION}-${BUILD_NUMBER}.tar.gz${NC}"

# Generate checksums
print_step "Generating checksums..."
cd $OUTPUT_DIR
find . -type f \( -name "*.apk" -o -name "*.aab" -o -name "*.app" -o -name "*.tar.gz" \) -exec sha256sum {} \; > checksums.txt
cd ..
print_success "Checksums generated"

echo ""
echo -e "${BLUE}🎉 Build process completed successfully!${NC}"
echo -e "${BLUE}🚀 Ready for deployment!${NC}"