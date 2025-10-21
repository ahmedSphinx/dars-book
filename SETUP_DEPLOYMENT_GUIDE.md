# DarsBook - Setup & Deployment Guide

## 🚀 Quick Start

This guide will help you set up and deploy the DarsBook Flutter application for development and production environments.

---

## 📋 Prerequisites

### Development Environment
- **Flutter SDK**: 3.0.0 or higher
- **Dart SDK**: 3.0.0 or higher
- **IDE**: Android Studio, VS Code, or IntelliJ IDEA
- **Git**: For version control
- **Node.js**: 16.0 or higher (for Firebase CLI)

### Platform-Specific Requirements

#### Android Development
- **Android Studio**: Latest stable version
- **Android SDK**: API level 21 (Android 5.0) or higher
- **Java Development Kit (JDK)**: 11 or higher
- **Android Emulator**: Or physical Android device

#### iOS Development (macOS only)
- **Xcode**: 14.0 or higher
- **iOS Simulator**: Or physical iOS device
- **CocoaPods**: For iOS dependencies
- **Apple Developer Account**: For app signing

#### Web Development
- **Chrome**: For web development and testing
- **Web Server**: For local development

---

## 🔧 Development Setup

### 1. Clone the Repository
```bash
git clone https://github.com/your-username/dars_book.git
cd dars_book
```

### 2. Install Flutter Dependencies
```bash
flutter pub get
```

### 3. Install Additional Tools
```bash
# Install FlutterFire CLI for Firebase configuration
dart pub global activate flutterfire_cli

# Install Firebase CLI
npm install -g firebase-tools

# Install CocoaPods (iOS only)
sudo gem install cocoapods
```

### 4. Verify Flutter Installation
```bash
flutter doctor
```

Ensure all required components are installed and configured properly.

---

## 🔥 Firebase Setup

### 1. Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project"
3. Enter project name: `darsbook` (or your preferred name)
4. Enable Google Analytics (recommended)
5. Choose or create Analytics account

### 2. Configure Firebase Services

#### Authentication
1. In Firebase Console, go to **Authentication** > **Sign-in method**
2. Enable **Phone** provider
3. Add your app's SHA-1 fingerprint (Android)
4. Configure OAuth consent screen (if needed)

#### Firestore Database
1. Go to **Firestore Database**
2. Click "Create database"
3. Choose "Start in test mode" (for development)
4. Select a location close to your users
5. Deploy security rules (see Security Rules section)

#### Cloud Functions
1. Go to **Functions**
2. Click "Get started"
3. Install Firebase CLI and login
4. Initialize Functions in your project

### 3. Configure Flutter App

#### Using FlutterFire CLI (Recommended)
```bash
# Login to Firebase
firebase login

# Configure Firebase for Flutter
flutterfire configure
```

#### Manual Configuration
1. Download configuration files:
   - `google-services.json` for Android
   - `GoogleService-Info.plist` for iOS
2. Place files in appropriate directories:
   - Android: `android/app/google-services.json`
   - iOS: `ios/Runner/GoogleService-Info.plist`

### 4. Update Firebase Configuration
```dart
// lib/firebase_options.dart
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.web:
        return web;
      default:
        throw UnsupportedError('Platform not supported');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'your-android-api-key',
    appId: 'your-android-app-id',
    messagingSenderId: 'your-sender-id',
    projectId: 'your-project-id',
    storageBucket: 'your-storage-bucket',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'your-ios-api-key',
    appId: 'your-ios-app-id',
    messagingSenderId: 'your-sender-id',
    projectId: 'your-project-id',
    storageBucket: 'your-storage-bucket',
    iosBundleId: 'com.yourcompany.darsbook',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'your-web-api-key',
    appId: 'your-web-app-id',
    messagingSenderId: 'your-sender-id',
    projectId: 'your-project-id',
    storageBucket: 'your-storage-bucket',
  );
}
```

---

## 🔒 Security Configuration

### 1. Firestore Security Rules
Deploy the security rules to your Firestore database:

```bash
# Deploy security rules
firebase deploy --only firestore:rules
```

### 2. Firebase Security Rules
```javascript
// firestore.rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Helper function to check ownership
    function isOwner(data) {
      return request.auth != null && data.ownerId == request.auth.uid;
    }
    
    // Helper function to check if user is authenticated
    function isAuthenticated() {
      return request.auth != null;
    }
    
    // Teachers collection
    match /teachers/{teacherId} {
      allow read, write: if isAuthenticated() && teacherId == request.auth.uid;
      
      // Students subcollection
      match /students/{studentId} {
        allow read, write: if isAuthenticated() && 
                              resource.data.ownerId == request.auth.uid;
      }
      
      // Add other collection rules...
    }
  }
}
```

### 3. Android App Signing
```bash
# Generate debug keystore (if not exists)
keytool -genkey -v -keystore ~/.android/debug.keystore -storepass android -alias androiddebugkey -keypass android -keyalg RSA -keysize 2048 -validity 10000

# Get SHA-1 fingerprint
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

### 4. iOS App Signing
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select the Runner target
3. Go to "Signing & Capabilities"
4. Select your development team
5. Enable "Automatically manage signing"

---

## 🏗️ Build Configuration

### 1. Android Build Configuration

#### Update `android/app/build.gradle.kts`
```kotlin
android {
    compileSdk 34
    
    defaultConfig {
        applicationId "com.yourcompany.darsbook"
        minSdk 21
        targetSdk 34
        versionCode 1
        versionName "1.0.0"
    }
    
    buildTypes {
        release {
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
            signingConfig signingConfigs.release
        }
    }
    
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
}
```

#### Create `android/key.properties`
```properties
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=your_key_alias
storeFile=path_to_your_keystore_file
```

### 2. iOS Build Configuration

#### Update `ios/Runner/Info.plist`
```xml
<key>CFBundleDisplayName</key>
<string>DarsBook</string>
<key>CFBundleIdentifier</key>
<string>com.yourcompany.darsbook</string>
<key>CFBundleVersion</key>
<string>1.0.0</string>
<key>CFBundleShortVersionString</key>
<string>1.0.0</string>
```

### 3. Web Build Configuration

#### Update `web/index.html`
```html
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta content="IE=Edge" http-equiv="X-UA-Compatible">
  <meta name="description" content="DarsBook - Student Management App">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>DarsBook</title>
  <link rel="manifest" href="manifest.json">
  <link rel="icon" type="image/png" href="favicon.png">
</head>
<body>
  <script src="main.dart.js" type="application/javascript"></script>
</body>
</html>
```

---

## 🚀 Running the Application

### 1. Development Mode
```bash
# Run on connected device/emulator
flutter run

# Run on specific platform
flutter run -d android
flutter run -d ios
flutter run -d web

# Run with specific flavor
flutter run --flavor development
```

### 2. Debug Mode
```bash
# Run in debug mode with hot reload
flutter run --debug

# Run with verbose logging
flutter run --verbose
```

### 3. Release Mode
```bash
# Run in release mode
flutter run --release
```

---

## 📱 Platform-Specific Setup

### Android Setup

#### 1. Configure Android Manifest
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.USE_FINGERPRINT" />
    <uses-permission android:name="android.permission.USE_BIOMETRIC" />
    
    <application
        android:label="DarsBook"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            
            <meta-data
                android:name="io.flutter.embedding.android.NormalTheme"
                android:resource="@style/NormalTheme" />
                
            <intent-filter android:autoVerify="true">
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
        
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
</manifest>
```

#### 2. Configure ProGuard Rules
```proguard
# android/app/proguard-rules.pro
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
```

### iOS Setup

#### 1. Configure iOS Info.plist
```xml
<!-- ios/Runner/Info.plist -->
<key>CFBundleDisplayName</key>
<string>DarsBook</string>
<key>CFBundleIdentifier</key>
<string>com.yourcompany.darsbook</string>
<key>CFBundleVersion</key>
<string>1.0.0</string>
<key>CFBundleShortVersionString</key>
<string>1.0.0</string>

<!-- Biometric Authentication -->
<key>NSFaceIDUsageDescription</key>
<string>Use Face ID to secure your app</string>
<key>NSBiometricUsageDescription</key>
<string>Use biometric authentication to secure your app</string>
```

#### 2. Configure Podfile
```ruby
# ios/Podfile
platform :ios, '12.0'

target 'Runner' do
  use_frameworks!
  use_modular_headers!

  flutter_install_all_ios_pods File.dirname(File.realpath(File.join(__FILE__, '..', '..')))
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
  end
end
```

#### 3. Install iOS Dependencies
```bash
cd ios
pod install
cd ..
```

### Web Setup

#### 1. Configure Web Manifest
```json
{
  "name": "DarsBook",
  "short_name": "DarsBook",
  "start_url": ".",
  "display": "standalone",
  "background_color": "#0175C2",
  "theme_color": "#0175C2",
  "description": "Student Management App for Teachers",
  "orientation": "portrait-primary",
  "prefer_related_applications": false,
  "icons": [
    {
      "src": "icons/Icon-192.png",
      "sizes": "192x192",
      "type": "image/png"
    },
    {
      "src": "icons/Icon-512.png",
      "sizes": "512x512",
      "type": "image/png"
    }
  ]
}
```

---

## 🏭 Production Deployment

### 1. Android Production Build

#### Generate Release APK
```bash
# Build release APK
flutter build apk --release

# Build App Bundle (recommended for Play Store)
flutter build appbundle --release
```

#### Sign Release Build
```bash
# Create keystore
keytool -genkey -v -keystore darsbook-release-key.keystore -alias darsbook -keyalg RSA -keysize 2048 -validity 10000

# Build signed APK
flutter build apk --release --split-per-abi
```

### 2. iOS Production Build

#### Archive for App Store
```bash
# Build iOS app
flutter build ios --release

# Archive in Xcode
# 1. Open ios/Runner.xcworkspace in Xcode
# 2. Select "Any iOS Device" as target
# 3. Product > Archive
# 4. Upload to App Store Connect
```

### 3. Web Production Build

#### Build for Web
```bash
# Build web app
flutter build web --release

# Deploy to Firebase Hosting
firebase deploy --only hosting
```

#### Configure Firebase Hosting
```json
{
  "hosting": {
    "public": "build/web",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ]
  }
}
```

---

## 🔧 Environment Configuration

### 1. Development Environment
```dart
// lib/core/constants/app_constants.dart
class AppConstants {
  static const String appName = 'DarsBook';
  static const String appVersion = '1.0.0';
  static const bool isDebugMode = kDebugMode;
  static const String environment = 'development';
  
  // Development-specific configurations
  static const String firebaseProjectId = 'darsbook-dev';
  static const bool enableLogging = true;
  static const bool enableAnalytics = false;
}
```

### 2. Production Environment
```dart
// lib/core/constants/app_constants.dart
class AppConstants {
  static const String appName = 'DarsBook';
  static const String appVersion = '1.0.0';
  static const bool isDebugMode = false;
  static const String environment = 'production';
  
  // Production-specific configurations
  static const String firebaseProjectId = 'darsbook-prod';
  static const bool enableLogging = false;
  static const bool enableAnalytics = true;
}
```

### 3. Environment-Specific Builds
```bash
# Development build
flutter run --dart-define=ENVIRONMENT=development

# Staging build
flutter run --dart-define=ENVIRONMENT=staging

# Production build
flutter run --dart-define=ENVIRONMENT=production
```

---

## 🧪 Testing Setup

### 1. Unit Testing
```bash
# Run unit tests
flutter test

# Run tests with coverage
flutter test --coverage

# Generate coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### 2. Integration Testing
```bash
# Run integration tests
flutter test integration_test/

# Run specific integration test
flutter test integration_test/app_test.dart
```

### 3. Widget Testing
```bash
# Run widget tests
flutter test test/widget_test.dart

# Run all tests
flutter test test/
```

---

## 📊 Monitoring & Analytics

### 1. Firebase Analytics
```dart
// Enable analytics in main.dart
import 'package:firebase_analytics/firebase_analytics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Enable analytics
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  await analytics.setAnalyticsCollectionEnabled(true);
  
  runApp(MyApp());
}
```

### 2. Crash Reporting
```dart
// Enable crash reporting
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Enable crash reporting
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  
  runApp(MyApp());
}
```

### 3. Performance Monitoring
```dart
// Enable performance monitoring
import 'package:firebase_performance/firebase_performance.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Enable performance monitoring
  FirebasePerformance performance = FirebasePerformance.instance;
  await performance.setPerformanceCollectionEnabled(true);
  
  runApp(MyApp());
}
```

---

## 🚨 Troubleshooting

### Common Issues

#### 1. Flutter Doctor Issues
```bash
# Update Flutter
flutter upgrade

# Clean Flutter cache
flutter clean
flutter pub get

# Reset Flutter
flutter doctor --android-licenses
```

#### 2. Firebase Configuration Issues
```bash
# Reconfigure Firebase
flutterfire configure

# Check Firebase project settings
firebase projects:list
firebase use --add
```

#### 3. Build Issues
```bash
# Clean build
flutter clean
flutter pub get

# Rebuild
flutter build apk --debug
flutter build ios --debug
flutter build web --debug
```

#### 4. iOS Build Issues
```bash
# Clean iOS build
cd ios
rm -rf Pods
rm Podfile.lock
pod install
cd ..

# Clean Xcode build
# In Xcode: Product > Clean Build Folder
```

#### 5. Android Build Issues
```bash
# Clean Android build
cd android
./gradlew clean
cd ..

# Check Android SDK
flutter doctor --android-licenses
```

---

## 📚 Additional Resources

### Documentation
- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Documentation](https://firebase.google.com/docs)
- [BLoC Documentation](https://bloclibrary.dev/)
- [Clean Architecture Guide](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

### Community
- [Flutter Community](https://flutter.dev/community)
- [Firebase Community](https://firebase.google.com/community)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter)

### Support
- **Email**: abdallhesam100@gmail.com
- **GitHub Issues**: [Create an issue](https://github.com/your-username/dars_book/issues)
- **Documentation**: [Project Wiki](https://github.com/your-username/dars_book/wiki)

---

## 🎯 Next Steps

### After Setup
1. **Test the app** on different devices and platforms
2. **Configure analytics** and monitoring
3. **Set up CI/CD** pipeline for automated builds
4. **Deploy to app stores** (Google Play, App Store)
5. **Monitor performance** and user feedback

### Development Workflow
1. **Create feature branch** for new features
2. **Write tests** for new functionality
3. **Submit pull request** for code review
4. **Merge to main** after approval
5. **Deploy to staging** for testing
6. **Deploy to production** after validation

---

**This setup guide provides comprehensive instructions for setting up and deploying the DarsBook application across all supported platforms.**
