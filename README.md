# DarsBook - دارس بوك

**A comprehensive SaaS application for private tutors to manage students, sessions, pricing, payments, and generate reports.**

Built with Flutter, Firebase, BLoC pattern, and Clean Architecture.

Created by **Abdalluh Essam** 🇪🇬
Email: abdallhesam100@gmail.com

---

## 🎯 Features

### Core Features (MVP)
- **📱 Phone Authentication**: Secure login using phone number and OTP
- **👥 Student Management**: Add, edit, delete, and manage students with detailed profiles
- **💰 Dynamic Pricing**: Set prices per academic year with custom pricing for individual students
- **📚 Session Management**: Create sessions, track attendance, and booklet distribution
- **📋 Session Templates**: Quick session creation with recurring templates
- **💳 Payment Tracking**: Record partial/full payments with multiple methods (cash, transfer, wallet)
- **📊 Dashboard & Reports**: Real-time insights, revenue tracking, and detailed reports
- **📅 Today's Collections**: Quick view of students with outstanding payments
- **🔒 App Security**: Biometric and PIN lock for data protection
- **🎨 Theme Support**: Light/Dark mode with Arabic (RTL) by default
- **🔐 Subscription System**: Voucher-based subscription management

### Advanced Features
- **Bulk Attendance**: Mark attendance for multiple students at once
- **Export Reports**: Generate PDF/CSV reports for students, sessions, and revenue
- **Custom Student Pricing**: Override default prices for specific students
- **Offline Support**: Full offline functionality with Firebase sync

---

## 🏗️ Architecture

### Clean Architecture Layers
```
lib/
├── core/               # Core utilities, DI, theme, routing
│   ├── constants/
│   ├── di/            # Dependency injection
│   ├── domain/        # Core entities (Subscription)
│   ├── errors/        # Error handling
│   ├── network/       # API client (Dio)
│   ├── routing/       # Navigation
│   ├── services/      # Firebase, shared services
│   ├── theme/         # App theming
│   └── utils/         # Shared utilities
│
├── features/          # Feature modules
│   ├── auth/
│   │   ├── data/      # Repository implementation, models
│   │   ├── domain/    # Entities, repositories (abstract)
│   │   └── presentation/  # BLoC, screens, widgets
│   ├── students/
│   ├── pricing/
│   ├── sessions/
│   ├── templates/
│   ├── payments/
│   ├── reports/
│   ├── dashboard/
│   ├── subscriptions/
│   ├── settings/
│   └── security/
│
├── main.dart
└── app.dart
```

### State Management
- **BLoC/Cubit** for business logic
- **Equatable** for value comparison
- **Get It** for dependency injection

---

## 🔥 Firebase Integration

### Services Used
- **Firebase Authentication** (Phone Auth)
- **Cloud Firestore** (Database with offline persistence)
- **Cloud Functions** (Voucher redemption, aggregations)
- **Firebase Storage** (Future: booklet uploads)
- **Firebase Cloud Messaging** (Future: payment reminders)

### Data Model
```
teachers/{uid}
  ├── students/{studentId}
  ├── prices/{year}
  ├── sessions/{sessionId}
  │   └── attendances/{studentId}
  ├── session_templates/{templateId}
  ├── payments/{paymentId}
  ├── metrics_daily/{YYYY-MM-DD}
  └── metrics_monthly/{YYYY-MM}

vouchers/{code} (admin only)
```

See [FIREBASE_SETUP.md](FIREBASE_SETUP.md) for detailed setup instructions.

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0.0+)
- Firebase project configured
- Android Studio / Xcode
- Firebase CLI (for cloud functions)

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/your-repo/dars_book.git
cd dars_book
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Configure Firebase**
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure
```

4. **Run the app**
```bash
flutter run
```

---

## 📦 Dependencies

### Core
- `flutter_bloc` - State management
- `equatable` - Value equality
- `get_it` - Dependency injection
- `dartz` - Functional programming

### Firebase
- `firebase_core` - Firebase initialization
- `firebase_auth` - Authentication
- `cloud_firestore` - Database
- `cloud_functions` - Cloud Functions
- `firebase_storage` - File storage

### UI/UX
- `go_router` - Navigation
- `easy_localization` - Internationalization
- `google_fonts` - Typography
- `flutter_animate` - Animations
- `lottie` - Lottie animations
- `dynamic_color` - Material You colors

### Security
- `local_auth` - Biometric authentication
- `flutter_secure_storage` - Secure storage

### Export
- `pdf` - PDF generation
- `printing` - PDF printing
- `csv` - CSV export

---

## 🌍 Localization

Default language: **Arabic (RTL)**

Supported languages:
- Arabic (ar)
- English (en)

Translation files: `assets/lang/`

---

## 🎨 Theming

- **Material 3** design system
- **Dynamic colors** on Android 12+
- **Dark/Light mode** support
- **Arabic fonts** (Cairo/Tajawal recommended)
- **RTL-first** UI design

---

## 💼 Business Model

### Subscription Tiers
- **Free Trial**: 7 days (optional)
- **Monthly**: 1 month access
- **Quarterly**: 3 months access (discount)
- **Annual**: 12 months access (best value)

### Monetization
- Manual voucher codes (MVP)
- Future: In-App Purchases (Google Play / App Store)
- Future: Stripe integration for web

---

## 🧪 Testing

### Run Tests
```bash
# Unit tests
flutter test

# Widget tests
flutter test test/widget_test.dart

# Integration tests (requires device/emulator)
flutter test integration_test/
```

### Code Coverage
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## 📱 Supported Platforms

- ✅ Android
- ✅ iOS
- 🚧 Web (limited support)
- ⏳ macOS/Windows (future)

---

## 🔐 Security

- Firestore security rules enforce data isolation per teacher
- Biometric/PIN app lock
- Secure storage for sensitive data
- Phone number authentication with OTP

---

## 🛠️ Development

### Code Generation
```bash
# Generate code for models/serialization
flutter pub run build_runner build --delete-conflicting-outputs
```

### Linting
```bash
flutter analyze
```

### Format
```bash
flutter format lib/
```

---

## 🤝 Contributing

Contributions are welcome! Please read CONTRIBUTING.md for details.

---

## 📞 Support

For support, email: abdallhesam100@gmail.com

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend infrastructure
- Open source community for packages

---

**Made with ❤️ for teachers worldwide by Abdalluh Essam**
