@echo off
REM VoiceCal Project Initialization Script for Windows
REM This script automates the setup of the VoiceCal Flutter project

setlocal enabledelayedexpansion

echo.
echo ========================================
echo    VoiceCal Project Initialization
echo ========================================
echo.

REM Check if Flutter is installed
echo [*] Checking Flutter installation...
where flutter >nul 2>nul
if %errorlevel% neq 0 (
    echo [!] Flutter is not installed!
    echo Please install Flutter from: https://flutter.dev/docs/get-started/install
    pause
    exit /b 1
)
echo [+] Flutter is installed
flutter --version
echo.

REM Create project structure
echo [*] Creating project structure...
if not exist "lib\screens" mkdir lib\screens
if not exist "lib\services" mkdir lib\services
if not exist "lib\models" mkdir lib\models
if not exist "lib\utils" mkdir lib\utils
echo [+] Directory structure created
echo.

REM Check for required files
echo [*] Checking required files...
set missing=0

if not exist "lib\main.dart" (
    echo [-] Missing: lib\main.dart
    set missing=1
)
if not exist "lib\screens\home_screen.dart" (
    echo [-] Missing: lib\screens\home_screen.dart
    set missing=1
)
if not exist "lib\screens\settings_screen.dart" (
    echo [-] Missing: lib\screens\settings_screen.dart
    set missing=1
)
if not exist "lib\services\audio_service.dart" (
    echo [-] Missing: lib\services\audio_service.dart
    set missing=1
)
if not exist "lib\services\speech_service.dart" (
    echo [-] Missing: lib\services\speech_service.dart
    set missing=1
)
if not exist "lib\services\calculation_service.dart" (
    echo [-] Missing: lib\services\calculation_service.dart
    set missing=1
)
if not exist "lib\services\tts_service.dart" (
    echo [-] Missing: lib\services\tts_service.dart
    set missing=1
)
if not exist "lib\models\calculation_result.dart" (
    echo [-] Missing: lib\models\calculation_result.dart
    set missing=1
)
if not exist "lib\utils\api_config.dart" (
    echo [-] Missing: lib\utils\api_config.dart
    set missing=1
)
if not exist "pubspec.yaml" (
    echo [-] Missing: pubspec.yaml
    set missing=1
)
if not exist "Makefile" (
    echo [-] Missing: Makefile
    set missing=1
)

if !missing! equ 1 (
    echo.
    echo [!] Setup incomplete - missing required files
    echo.
    echo Please ensure you have copied all files from the artifacts:
    echo   1. All lib\ directory files
    echo   2. pubspec.yaml
    echo   3. Makefile
    echo   4. Android and iOS configuration files
    echo.
    echo Then run this script again.
    pause
    exit /b 1
)
echo [+] All required files present
echo.

REM Create .gitignore if it doesn't exist
if not exist ".gitignore" (
    echo [*] Creating .gitignore...
    (
        echo # Flutter/Dart
        echo .dart_tool/
        echo .flutter-plugins
        echo .flutter-plugins-dependencies
        echo .packages
        echo build/
        echo.
        echo # IDE
        echo .idea/
        echo .vscode/
        echo *.iml
        echo *.ipr
        echo *.iws
        echo.
        echo # Android
        echo android/local.properties
        echo android/.gradle/
        echo android/app/debug/
        echo android/app/profile/
        echo android/app/release/
        echo.
        echo # iOS
        echo ios/Pods/
        echo ios/.symlinks/
        echo ios/Flutter/Flutter.framework
        echo ios/Flutter/Flutter.podspec
        echo.
        echo # API Keys - IMPORTANT!
        echo android/key.properties
        echo.
        echo # OS
        echo .DS_Store
        echo Thumbs.db
    ) > .gitignore
    echo [+] .gitignore created
    echo.
)

REM Install dependencies
echo [*] Installing Flutter dependencies...
flutter pub get
if %errorlevel% neq 0 (
    echo [!] Failed to install dependencies
    pause
    exit /b 1
)
echo [+] Dependencies installed
echo.

REM Run Flutter doctor
echo [*] Running Flutter doctor...
flutter doctor
echo.
echo [!] Please fix any issues reported by 'flutter doctor' before building
echo.

REM List available devices
echo [*] Checking available devices...
flutter devices
echo.

REM Success message
echo ========================================
echo [+] VoiceCal setup complete!
echo ========================================
echo.
echo Next steps:
echo   1. Configure API keys:
echo      - Get OpenAI key: https://platform.openai.com/api-keys
echo      - Get Anthropic key: https://console.anthropic.com/
echo.
echo   2. Run the app:
echo      flutter run                  # Run on connected device
echo      flutter run -d chrome        # Run on web
echo.
echo   3. Build for production:
echo      flutter build apk --release  # Build Android APK
echo      flutter build web --release  # Build web app
echo.
echo For detailed instructions, see:
echo   - QUICKSTART.md (5-minute start)
echo   - SETUP_GUIDE.md (complete guide)
echo   - README.md (full documentation)
echo.
echo Happy coding! 🎉
echo.
pause