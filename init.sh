#!/bin/bash

# VoiceCal Project Initialization Script
# This script automates the setup of the VoiceCal Flutter project

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored output
print_step() {
    echo -e "${BLUE}==>${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Check if Flutter is installed
check_flutter() {
    print_step "Checking Flutter installation..."
    
    if ! command -v flutter &> /dev/null; then
        print_error "Flutter is not installed!"
        echo "Please install Flutter from: https://flutter.dev/docs/get-started/install"
        exit 1
    fi
    
    print_success "Flutter is installed"
    flutter --version
}

# Create project structure
create_structure() {
    print_step "Creating project structure..."
    
    # Create directories
    mkdir -p lib/screens
    mkdir -p lib/services
    mkdir -p lib/models
    mkdir -p lib/utils
    
    print_success "Directory structure created"
}

# Check if required files exist
check_files() {
    print_step "Checking required files..."
    
    required_files=(
        "lib/main.dart"
        "lib/screens/home_screen.dart"
        "lib/screens/settings_screen.dart"
        "lib/services/audio_service.dart"
        "lib/services/speech_service.dart"
        "lib/services/calculation_service.dart"
        "lib/services/tts_service.dart"
        "lib/models/calculation_result.dart"
        "lib/utils/api_config.dart"
        "pubspec.yaml"
        "Makefile"
    )
    
    missing_files=()
    
    for file in "${required_files[@]}"; do
        if [ ! -f "$file" ]; then
            missing_files+=("$file")
        fi
    done
    
    if [ ${#missing_files[@]} -gt 0 ]; then
        print_warning "Missing files detected:"
        for file in "${missing_files[@]}"; do
            echo "  - $file"
        done
        print_warning "Please ensure all files are copied to the project"
        return 1
    fi
    
    print_success "All required files present"
    return 0
}

# Install dependencies
install_dependencies() {
    print_step "Installing Flutter dependencies..."
    
    flutter pub get
    
    print_success "Dependencies installed"
}

# Verify permissions in AndroidManifest.xml
check_android_permissions() {
    print_step "Checking Android permissions..."
    
    manifest_file="android/app/src/main/AndroidManifest.xml"
    
    if [ ! -f "$manifest_file" ]; then
        print_warning "AndroidManifest.xml not found - will be created on first Android build"
        return 0
    fi
    
    required_permissions=(
        "android.permission.INTERNET"
        "android.permission.RECORD_AUDIO"
    )
    
    missing_permissions=()
    
    for permission in "${required_permissions[@]}"; do
        if ! grep -q "$permission" "$manifest_file"; then
            missing_permissions+=("$permission")
        fi
    done
    
    if [ ${#missing_permissions[@]} -gt 0 ]; then
        print_warning "Missing Android permissions:"
        for permission in "${missing_permissions[@]}"; do
            echo "  - $permission"
        done
        print_warning "Please update AndroidManifest.xml manually"
    else
        print_success "Android permissions configured"
    fi
}

# Verify iOS permissions
check_ios_permissions() {
    print_step "Checking iOS permissions..."
    
    plist_file="ios/Runner/Info.plist"
    
    if [ ! -f "$plist_file" ]; then
        print_warning "Info.plist not found - will be created on first iOS build"
        return 0
    fi
    
    if grep -q "NSMicrophoneUsageDescription" "$plist_file"; then
        print_success "iOS permissions configured"
    else
        print_warning "Missing iOS microphone permission in Info.plist"
    fi
}

# Run Flutter doctor
run_flutter_doctor() {
    print_step "Running Flutter doctor..."
    
    flutter doctor
    
    echo ""
    print_warning "Please fix any issues reported by 'flutter doctor' before building"
}

# List available devices
list_devices() {
    print_step "Checking available devices..."
    
    flutter devices
    
    echo ""
}

# Create .gitignore if it doesn't exist
create_gitignore() {
    if [ ! -f ".gitignore" ]; then
        print_step "Creating .gitignore..."
        
        cat > .gitignore << 'EOF'
# Flutter/Dart
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
build/

# IDE
.idea/
.vscode/
*.iml
*.ipr
*.iws

# Android
android/local.properties
android/.gradle/
android/app/debug/
android/app/profile/
android/app/release/

# iOS
ios/Pods/
ios/.symlinks/
ios/Flutter/Flutter.framework
ios/Flutter/Flutter.podspec

# API Keys - IMPORTANT!
android/key.properties

# OS
.DS_Store
Thumbs.db
EOF
        
        print_success ".gitignore created"
    fi
}

# Main setup function
main() {
    echo ""
    echo "========================================"
    echo "   VoiceCal Project Initialization"
    echo "========================================"
    echo ""
    
    # Check Flutter
    check_flutter
    echo ""
    
    # Create structure
    create_structure
    echo ""
    
    # Check files
    if ! check_files; then
        echo ""
        print_error "Setup incomplete - missing required files"
        echo ""
        echo "Please ensure you have copied all files from the artifacts:"
        echo "  1. All lib/ directory files"
        echo "  2. pubspec.yaml"
        echo "  3. Makefile"
        echo "  4. Android and iOS configuration files"
        echo ""
        echo "Then run this script again."
        exit 1
    fi
    echo ""
    
    # Create .gitignore
    create_gitignore
    echo ""
    
    # Install dependencies
    install_dependencies
    echo ""
    
    # Check Android permissions
    check_android_permissions
    echo ""
    
    # Check iOS permissions (only on macOS)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        check_ios_permissions
        echo ""
    fi
    
    # Run Flutter doctor
    run_flutter_doctor
    echo ""
    
    # List devices
    list_devices
    echo ""
    
    # Success message
    echo "========================================"
    print_success "VoiceCal setup complete!"
    echo "========================================"
    echo ""
    echo "Next steps:"
    echo "  1. Configure API keys:"
    echo "     - Get OpenAI key: https://platform.openai.com/api-keys"
    echo "     - Get Anthropic key: https://console.anthropic.com/"
    echo ""
    echo "  2. Run the app:"
    echo "     ${GREEN}flutter run${NC}                  # Run on connected device"
    echo "     ${GREEN}flutter run -d chrome${NC}        # Run on web"
    echo "     ${GREEN}make run${NC}                     # Run using Makefile"
    echo ""
    echo "  3. Build for production:"
    echo "     ${GREEN}make android${NC}                 # Build Android APK"
    echo "     ${GREEN}make web${NC}                     # Build web app"
    echo "     ${GREEN}make all${NC}                     # Build multiple platforms"
    echo ""
    echo "For detailed instructions, see:"
    echo "  - ${BLUE}QUICKSTART.md${NC} (5-minute start)"
    echo "  - ${BLUE}SETUP_GUIDE.md${NC} (complete guide)"
    echo "  - ${BLUE}README.md${NC} (full documentation)"
    echo ""
    echo "Happy coding! 🎉"
    echo ""
}

# Run main function
main