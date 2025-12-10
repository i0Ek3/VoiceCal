# VoiceCal - Voice-Powered Calculator

A cross-platform voice calculator application that uses AI to understand natural language math expressions and compute results. Supports Chinese and English with advanced mathematical operations.

## Features

- 🎤 **Voice Input**: Record audio to input math expressions
- 🤖 **AI-Powered**: Uses OpenAI Whisper for speech recognition and Claude for intent understanding
- 🌍 **Multilingual**: Supports Chinese (个十百千万亿) and English (dozen, hundred, thousand)
- 🔢 **Advanced Math**: Handles basic operations, square roots, powers, trigonometric functions
- 🔊 **Voice Output**: Optional text-to-speech for results
- ✏️ **Text Editing**: Review and edit recognized text before calculation
- 📱 **Cross-Platform**: Works on Android, iOS, Web, Windows, macOS, Linux

## Prerequisites

- Flutter SDK 3.10.0 or higher
- Dart SDK 3.0.0 or higher
- For Android: Android Studio / Android SDK
- For iOS: Xcode 14+ (macOS only)
- For Web: Chrome/Edge/Safari

## Quick Start

### 1. Clone and Setup

```bash
# Clone the repository
git clone <repository-url>
cd voicecal

# Install dependencies
flutter pub get
```

### 2. Configure API Keys

The app requires API keys for AI services:

**Option A: Use Built-in Keys (for testing)**
- The app includes placeholder keys for demo purposes
- Limited usage quota

**Option B: Use Your Own Keys (recommended)**
1. Launch the app
2. Go to Settings (gear icon)
3. Enter your API keys:
   - **OpenAI API Key**: Get from https://platform.openai.com/api-keys
   - **Anthropic API Key**: Get from https://console.anthropic.com/

### 3. Run the App

```bash
# Run on connected device/emulator
flutter run

# Run on specific platform
flutter run -d chrome          # Web
flutter run -d android          # Android
flutter run -d ios              # iOS (macOS only)
flutter run -d windows          # Windows
flutter run -d macos            # macOS
flutter run -d linux            # Linux
```

## Build for Production

### One-Command Build (All Platforms)

```bash
# Build all platforms
make all

# Or build specific platforms
make android    # Build APK
make ios        # Build iOS (macOS only)
make web        # Build Web
make windows    # Build Windows
make macos      # Build macOS
make linux      # Build Linux
```

### Manual Build Commands

#### Android (APK)
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

#### Android (App Bundle for Google Play)
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

#### iOS (requires macOS)
```bash
flutter build ios --release
# Then open ios/Runner.xcworkspace in Xcode to archive
```

#### Web
```bash
flutter build web --release
# Output: build/web/
# Deploy to any static hosting service
```

#### Windows
```bash
flutter build windows --release
# Output: build/windows/runner/Release/
```

#### macOS
```bash
flutter build macos --release
# Output: build/macos/Build/Products/Release/
```

#### Linux
```bash
flutter build linux --release
# Output: build/linux/x64/release/bundle/
```

## Project Structure

```
voicecal/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── screens/
│   │   ├── home_screen.dart      # Main calculator interface
│   │   └── settings_screen.dart  # API key configuration
│   ├── services/
│   │   ├── audio_service.dart    # Audio recording
│   │   ├── speech_service.dart   # Speech-to-text (Whisper)
│   │   ├── calculation_service.dart # Math calculation (Claude)
│   │   └── tts_service.dart      # Text-to-speech
│   ├── models/
│   │   └── calculation_result.dart # Data models
│   └── utils/
│       └── api_config.dart       # API configuration
├── android/                      # Android-specific files
├── ios/                          # iOS-specific files
├── web/                          # Web-specific files
├── windows/                      # Windows-specific files
├── macos/                        # macOS-specific files
├── linux/                        # Linux-specific files
├── Makefile                      # Build automation
└── pubspec.yaml                  # Dependencies
```

## Usage Guide

### Basic Workflow

1. **Record Voice Input**
   - Tap and hold the microphone button
   - Speak your math expression (e.g., "Calculate 30 times 10000 divided by 20000 as a percentage")
   - Release to stop recording

2. **Review Transcription**
   - The recognized text appears automatically
   - Edit if needed using the text field

3. **Calculate**
   - Tap "Calculate" button
   - Result displays with optional voice readback

4. **Settings**
   - Configure your own API keys
   - Toggle voice output on/off
   - Select language preference

### Supported Expressions

#### Basic Operations
- Addition: "5 plus 3", "五加三"
- Subtraction: "10 minus 4", "十减四"
- Multiplication: "6 times 7", "六乘以七"
- Division: "20 divided by 4", "二十除以四"

#### Advanced Operations
- Square root: "square root of 16", "十六的平方根"
- Power: "2 to the power of 8", "二的八次方"
- Percentage: "what is 25% of 200", "二百的百分之二十五"
- Trigonometry: "sine of 30 degrees", "三十度的正弦"

#### Complex Expressions
- "Calculate 30 times 10000 divided by 20000 as a percentage"
- "请帮我计算三十乘以一万除以两万，给出百分比"

## API Configuration

### OpenAI Whisper API
- **Purpose**: Speech-to-text conversion
- **Model**: whisper-1
- **Supported Languages**: 50+ languages including Chinese and English
- **Get Key**: https://platform.openai.com/api-keys

### Anthropic Claude API
- **Purpose**: Natural language understanding and calculation
- **Model**: claude-sonnet-4-20250514
- **Get Key**: https://console.anthropic.com/

### Built-in Keys (Limited)
```dart
// Default keys in lib/utils/api_config.dart
static const String defaultOpenAIKey = 'your-demo-key';
static const String defaultAnthropicKey = 'your-demo-key';
```

## Troubleshooting

### Microphone Permission Denied
- **Android**: Grant microphone permission in Settings > Apps > VoiceCal
- **iOS**: Grant microphone permission when prompted
- **Web**: Allow microphone access in browser

### Build Errors

#### Android
```bash
# Clean build
flutter clean
flutter pub get
flutter build apk --release
```

#### iOS
```bash
# Update pods
cd ios
pod install --repo-update
cd ..
flutter build ios --release
```

### API Errors
- Verify API keys are correct
- Check internet connection
- Ensure API quota is not exceeded

## Development

### Add New Features

1. **Add Dependencies**
```bash
flutter pub add package_name
```

2. **Update Code**
```bash
# Run in development mode with hot reload
flutter run
```

3. **Test on Multiple Platforms**
```bash
flutter test
flutter run -d android
flutter run -d ios
flutter run -d chrome
```

### Code Style
```bash
# Format code
flutter format .

# Analyze code
flutter analyze
```

## Deployment

### Android (Google Play Store)
1. Build app bundle: `flutter build appbundle --release`
2. Sign with keystore
3. Upload to Google Play Console

### iOS (App Store)
1. Build in Xcode: `flutter build ios --release`
2. Archive and sign
3. Upload via App Store Connect

### Web
1. Build: `flutter build web --release`
2. Deploy `build/web/` to:
   - Firebase Hosting
   - Netlify
   - Vercel
   - GitHub Pages

## Performance Tips

- First launch may take 2-3 seconds (loading AI models)
- Audio recording is optimized for low latency
- Web version works best in Chrome/Edge

## License

MIT License - feel free to use and modify

## Support

For issues and feature requests, please open an issue on GitHub.

## Credits

- Flutter Framework
- OpenAI Whisper API
- Anthropic Claude API
- Flutter TTS Plugin
- Record Audio Plugin