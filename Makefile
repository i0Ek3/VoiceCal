.PHONY: all clean android ios web windows macos linux setup help

# Default target
all: setup android web

# Help target
help:
	@echo "VoiceCal Build System"
	@echo "===================="
	@echo ""
	@echo "Available targets:"
	@echo "  make setup      - Install dependencies"
	@echo "  make android    - Build Android APK"
	@echo "  make ios        - Build iOS app (macOS only)"
	@echo "  make web        - Build Web app"
	@echo "  make windows    - Build Windows app"
	@echo "  make macos      - Build macOS app"
	@echo "  make linux      - Build Linux app"
	@echo "  make all        - Build Android and Web"
	@echo "  make clean      - Clean build files"
	@echo "  make run        - Run in debug mode"
	@echo ""

# Setup dependencies
setup:
	@echo "Installing dependencies..."
	flutter pub get
	@echo "Setup complete!"

# Clean build files
clean:
	@echo "Cleaning build files..."
	flutter clean
	@echo "Clean complete!"

# Run in debug mode
run:
	@echo "Running VoiceCal in debug mode..."
	flutter run

# Build Android APK
android:
	@echo "Building Android APK..."
	flutter build apk --release
	@echo "APK built successfully!"
	@echo "Location: build/app/outputs/flutter-apk/app-release.apk"

# Build Android App Bundle (for Play Store)
android-bundle:
	@echo "Building Android App Bundle..."
	flutter build appbundle --release
	@echo "App Bundle built successfully!"
	@echo "Location: build/app/outputs/bundle/release/app-release.aab"

# Build iOS (requires macOS)
ios:
	@echo "Building iOS app..."
	flutter build ios --release
	@echo "iOS build complete!"
	@echo "Open ios/Runner.xcworkspace in Xcode to archive"

# Build Web
web:
	@echo "Building Web app..."
	flutter build web --release
	@echo "Web app built successfully!"
	@echo "Location: build/web/"

# Build Windows
windows:
	@echo "Building Windows app..."
	flutter build windows --release
	@echo "Windows app built successfully!"
	@echo "Location: build/windows/runner/Release/"

# Build macOS
macos:
	@echo "Building macOS app..."
	flutter build macos --release
	@echo "macOS app built successfully!"
	@echo "Location: build/macos/Build/Products/Release/"

# Build Linux
linux:
	@echo "Building Linux app..."
	flutter build linux --release
	@echo "Linux app built successfully!"
	@echo "Location: build/linux/x64/release/bundle/"

# Format code
format:
	@echo "Formatting code..."
	flutter format .
	@echo "Format complete!"

# Analyze code
analyze:
	@echo "Analyzing code..."
	flutter analyze
	@echo "Analysis complete!"

# Run tests
test:
	@echo "Running tests..."
	flutter test
	@echo "Tests complete!"

# Development mode with hot reload
dev:
	@echo "Starting development mode..."
	flutter run -d chrome

# Build all desktop platforms
desktop: windows macos linux

# Build all mobile platforms
mobile: android ios

# Build everything
build-all: android ios web windows macos linux