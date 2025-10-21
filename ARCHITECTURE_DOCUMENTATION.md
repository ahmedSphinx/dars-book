# DarsBook - Architecture Documentation

## 🏗️ Clean Architecture Overview

DarsBook follows **Clean Architecture** principles, ensuring separation of concerns, testability, and maintainability. The architecture is organized into distinct layers with clear dependencies and responsibilities.

### Architecture Principles
- **Dependency Inversion**: High-level modules don't depend on low-level modules
- **Separation of Concerns**: Each layer has a single responsibility
- **Testability**: Each layer can be tested independently
- **Maintainability**: Changes in one layer don't affect others
- **Scalability**: Easy to add new features and modify existing ones

---

## 📁 Project Structure

```
lib/
├── core/                    # Core utilities and shared components
│   ├── bloc/               # Global BLoCs (Theme)
│   ├── constants/          # App constants and configuration
│   ├── di/                 # Dependency injection setup
│   ├── domain/             # Core domain entities
│   ├── errors/             # Error handling and custom exceptions
│   ├── extensions/         # Dart extensions for utilities
│   ├── network/            # Network layer (Dio, API consumer)
│   ├── routing/            # Navigation and routing
│   ├── services/           # Core services (Firebase, Theme)
│   ├── theme/              # App theming and styling
│   └── utils/              # Shared utilities and helpers
│
├── features/               # Feature modules (Clean Architecture)
│   ├── auth/               # Authentication feature
│   │   ├── data/           # Data layer implementation
│   │   │   ├── models/     # Data models (DTOs)
│   │   │   └── repositories/ # Repository implementations
│   │   ├── domain/         # Domain layer
│   │   │   ├── entities/   # Business entities
│   │   │   └── repositories/ # Repository interfaces
│   │   └── presentation/   # Presentation layer
│   │       ├── bloc/       # BLoC state management
│   │       ├── screens/    # UI screens
│   │       └── widgets/    # Reusable UI components
│   │
│   ├── students/           # Student management feature
│   ├── sessions/           # Session management feature
│   ├── payments/           # Payment processing feature
│   ├── reports/            # Analytics and reporting feature
│   ├── settings/           # App settings feature
│   ├── security/           # App security feature
│   ├── subscriptions/      # Subscription management feature
│   ├── teacher_profile/    # Teacher profile feature
│   └── templates/          # Session templates feature
│
├── main.dart               # App entry point
└── app.dart                # App configuration
```

---

## 🎯 Clean Architecture Layers

### 1. Presentation Layer
**Responsibility**: UI, user interactions, and state management

#### Components:
- **Screens**: User interface screens
- **Widgets**: Reusable UI components
- **BLoCs**: Business logic controllers for state management
- **Events**: User actions and system events
- **States**: UI state representations

#### Key Principles:
- UI components are stateless and reactive
- Business logic is handled by BLoCs
- No direct data access from UI
- Clear separation between UI and business logic

#### Example Structure:
```dart
// BLoC for state management
class StudentsBloc extends Bloc<StudentsEvent, StudentsState> {
  final StudentRepository repository;
  
  StudentsBloc({required this.repository}) : super(StudentsInitial()) {
    on<LoadStudents>(_onLoadStudents);
    on<AddStudent>(_onAddStudent);
    on<UpdateStudent>(_onUpdateStudent);
    on<DeleteStudent>(_onDeleteStudent);
  }
}

// Events
abstract class StudentsEvent extends Equatable {
  const StudentsEvent();
}

class LoadStudents extends StudentsEvent {
  @override
  List<Object> get props => [];
}

// States
abstract class StudentsState extends Equatable {
  const StudentsState();
}

class StudentsInitial extends StudentsState {
  @override
  List<Object> get props => [];
}

class StudentsLoading extends StudentsState {
  @override
  List<Object> get props => [];
}

class StudentsLoaded extends StudentsState {
  final List<Student> students;
  
  const StudentsLoaded(this.students);
  
  @override
  List<Object> get props => [students];
}
```

### 2. Domain Layer
**Responsibility**: Business logic, entities, and use cases

#### Components:
- **Entities**: Core business objects
- **Repositories**: Abstract data access interfaces
- **Use Cases**: Business logic implementation
- **Value Objects**: Immutable data structures

#### Key Principles:
- Independent of external frameworks
- Contains pure business logic
- No dependencies on presentation or data layers
- Defines contracts for data access

#### Example Structure:
```dart
// Entity
class Student extends Equatable {
  final String id;
  final String name;
  final String? phone;
  final String year;
  final bool isActive;
  final StudentAggregates aggregates;
  
  const Student({
    required this.id,
    required this.name,
    this.phone,
    required this.year,
    this.isActive = true,
    this.aggregates = const StudentAggregates(),
  });
}

// Repository Interface
abstract class StudentRepository {
  Future<Either<Failure, List<Student>>> getStudents();
  Future<Either<Failure, Student>> getStudent(String id);
  Future<Either<Failure, Student>> addStudent(Student student);
  Future<Either<Failure, Student>> updateStudent(Student student);
  Future<Either<Failure, void>> deleteStudent(String id);
  Stream<List<Student>> watchStudents();
}

// Use Case
class GetStudentsUseCase {
  final StudentRepository repository;
  
  GetStudentsUseCase(this.repository);
  
  Future<Either<Failure, List<Student>>> call() async {
    return await repository.getStudents();
  }
}
```

### 3. Data Layer
**Responsibility**: Data access, external services, and data sources

#### Components:
- **Repository Implementations**: Concrete data access
- **Data Sources**: Firebase, local storage, APIs
- **Models**: Data transfer objects (DTOs)
- **Mappers**: Entity-model conversions

#### Key Principles:
- Implements domain layer interfaces
- Handles data transformation
- Manages external dependencies
- Provides data caching and offline support

#### Example Structure:
```dart
// Data Model (DTO)
class StudentModel extends Student {
  const StudentModel({
    required super.id,
    required super.name,
    super.phone,
    required super.year,
    super.isActive,
    super.aggregates,
  });
  
  factory StudentModel.fromJson(Map<String, dynamic> json, String id) {
    return StudentModel(
      id: id,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      year: json['year'] as String,
      isActive: json['isActive'] as bool? ?? true,
      aggregates: StudentAggregatesModel.fromJson(json['aggregates']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'year': year,
      'isActive': isActive,
      'aggregates': (aggregates as StudentAggregatesModel).toJson(),
    };
  }
}

// Repository Implementation
class StudentRepositoryImpl implements StudentRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;
  
  StudentRepositoryImpl({
    required this.firestore,
    required this.firebaseAuth,
  });
  
  @override
  Future<Either<Failure, List<Student>>> getStudents() async {
    try {
      final uid = firebaseAuth.currentUser?.uid;
      if (uid == null) {
        return const Left(AuthFailure('User not authenticated'));
      }
      
      final snapshot = await firestore
          .collection('teachers')
          .doc(uid)
          .collection('students')
          .where('isActive', isEqualTo: true)
          .get();
      
      final students = snapshot.docs
          .map((doc) => StudentModel.fromJson(doc.data(), doc.id))
          .toList();
      
      return Right(students);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Unknown error'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}
```

---

## 🔄 State Management (BLoC Pattern)

### BLoC Architecture
The app uses the **BLoC (Business Logic Component)** pattern for state management, providing:
- **Predictable state changes**
- **Testable business logic**
- **Reactive programming**
- **Separation of concerns**

### BLoC Components

#### 1. Events
Represent user actions or system events that trigger state changes.

```dart
abstract class StudentsEvent extends Equatable {
  const StudentsEvent();
}

class LoadStudents extends StudentsEvent {
  @override
  List<Object> get props => [];
}

class AddStudent extends StudentsEvent {
  final Student student;
  
  const AddStudent(this.student);
  
  @override
  List<Object> get props => [student];
}

class UpdateStudent extends StudentsEvent {
  final Student student;
  
  const UpdateStudent(this.student);
  
  @override
  List<Object> get props => [student];
}

class DeleteStudent extends StudentsEvent {
  final String studentId;
  
  const DeleteStudent(this.studentId);
  
  @override
  List<Object> get props => [studentId];
}
```

#### 2. States
Represent the current state of the application.

```dart
abstract class StudentsState extends Equatable {
  const StudentsState();
}

class StudentsInitial extends StudentsState {
  @override
  List<Object> get props => [];
}

class StudentsLoading extends StudentsState {
  @override
  List<Object> get props => [];
}

class StudentsLoaded extends StudentsState {
  final List<Student> students;
  
  const StudentsLoaded(this.students);
  
  @override
  List<Object> get props => [students];
}

class StudentsError extends StudentsState {
  final String message;
  
  const StudentsError(this.message);
  
  @override
  List<Object> get props => [message];
}
```

#### 3. BLoC
Handles business logic and state transitions.

```dart
class StudentsBloc extends Bloc<StudentsEvent, StudentsState> {
  final StudentRepository repository;
  
  StudentsBloc({required this.repository}) : super(StudentsInitial()) {
    on<LoadStudents>(_onLoadStudents);
    on<AddStudent>(_onAddStudent);
    on<UpdateStudent>(_onUpdateStudent);
    on<DeleteStudent>(_onDeleteStudent);
  }
  
  Future<void> _onLoadStudents(
    LoadStudents event,
    Emitter<StudentsState> emit,
  ) async {
    emit(StudentsLoading());
    
    final result = await repository.getStudents();
    result.fold(
      (failure) => emit(StudentsError(failure.message)),
      (students) => emit(StudentsLoaded(students)),
    );
  }
  
  Future<void> _onAddStudent(
    AddStudent event,
    Emitter<StudentsState> emit,
  ) async {
    final result = await repository.addStudent(event.student);
    result.fold(
      (failure) => emit(StudentsError(failure.message)),
      (student) {
        if (state is StudentsLoaded) {
          final currentStudents = (state as StudentsLoaded).students;
          emit(StudentsLoaded([...currentStudents, student]));
        }
      },
    );
  }
}
```

---

## 🔧 Dependency Injection

### Get It Service Locator
The app uses **Get It** for dependency injection, providing:
- **Singleton management**
- **Lazy initialization**
- **Easy testing with mocks**
- **Centralized dependency management**

### DI Setup
```dart
final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // External dependencies
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseFunctions.instance);
  sl.registerLazySingleton(() => const FlutterSecureStorage());
  
  // Repositories
  sl.registerLazySingleton<StudentRepository>(
    () => StudentRepositoryImpl(
      firestore: sl(),
      firebaseAuth: sl(),
    ),
  );
  
  sl.registerLazySingleton<SessionRepository>(
    () => SessionRepositoryImpl(
      firestore: sl(),
      firebaseAuth: sl(),
    ),
  );
  
  // BLoCs
  sl.registerFactory(() => StudentsBloc(
    studentRepository: sl(),
  ));
  
  sl.registerFactory(() => SessionsBloc(
    sessionRepository: sl(),
  ));
}
```

### Usage in Widgets
```dart
class StudentsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<StudentsBloc>()..add(LoadStudents()),
      child: BlocBuilder<StudentsBloc, StudentsState>(
        builder: (context, state) {
          if (state is StudentsLoading) {
            return const CircularProgressIndicator();
          } else if (state is StudentsLoaded) {
            return ListView.builder(
              itemCount: state.students.length,
              itemBuilder: (context, index) {
                final student = state.students[index];
                return StudentCard(student: student);
              },
            );
          } else if (state is StudentsError) {
            return Text('Error: ${state.message}');
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
```

---

## 🌐 Network Layer

### API Consumer Pattern
The app uses an abstract API consumer for network operations:

```dart
abstract class ApiConsumer {
  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters});
  Future<dynamic> post(String path, {Map<String, dynamic>? body});
  Future<dynamic> put(String path, {Map<String, dynamic>? body});
  Future<dynamic> delete(String path);
}

class DioConsumer implements ApiConsumer {
  final Dio dio;
  
  DioConsumer({required this.dio});
  
  @override
  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) async {
    final response = await dio.get(path, queryParameters: queryParameters);
    return response.data;
  }
  
  @override
  Future<dynamic> post(String path, {Map<String, dynamic>? body}) async {
    final response = await dio.post(path, data: body);
    return response.data;
  }
}
```

### Firebase Integration
```dart
class FirebaseService {
  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  
  static FirebaseAuth get auth => FirebaseAuth.instance;
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;
  static FirebaseFunctions get functions => FirebaseFunctions.instance;
}
```

---

## 🎨 Theme Architecture

### Theme System
The app uses a comprehensive theming system with:
- **Material 3 design**
- **Dynamic color support**
- **Light/Dark mode**
- **RTL support**
- **Custom color schemes**

### Theme Structure
```dart
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      textTheme: GoogleFonts.cairoTextTheme(),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
    );
  }
  
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
      ),
      textTheme: GoogleFonts.cairoTextTheme(
        ThemeData.dark().textTheme,
      ),
    );
  }
}
```

### Theme Management
```dart
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final ThemeService themeService;
  
  ThemeBloc({required this.themeService}) : super(ThemeInitial()) {
    on<LoadTheme>(_onLoadTheme);
    on<ToggleTheme>(_onToggleTheme);
  }
  
  Future<void> _onLoadTheme(LoadTheme event, Emitter<ThemeState> emit) async {
    final themeMode = await themeService.getThemeMode();
    emit(ThemeLoaded(themeMode));
  }
  
  Future<void> _onToggleTheme(ToggleTheme event, Emitter<ThemeState> emit) async {
    final newThemeMode = event.themeMode;
    await themeService.setThemeMode(newThemeMode);
    emit(ThemeLoaded(newThemeMode));
  }
}
```

---

## 🧪 Testing Architecture

### Testing Strategy
The app follows a comprehensive testing strategy:
- **Unit Tests**: Test individual components
- **Widget Tests**: Test UI components
- **Integration Tests**: Test complete user flows
- **BLoC Tests**: Test state management logic

### Test Structure
```
test/
├── unit/                   # Unit tests
│   ├── features/          # Feature-specific unit tests
│   ├── core/              # Core functionality tests
│   └── mocks/             # Mock objects
├── widget/                # Widget tests
│   └── features/          # Feature-specific widget tests
└── integration/           # Integration tests
    └── features/          # End-to-end tests
```

### Example Unit Test
```dart
void main() {
  group('StudentsBloc', () {
    late StudentsBloc studentsBloc;
    late MockStudentRepository mockRepository;
    
    setUp(() {
      mockRepository = MockStudentRepository();
      studentsBloc = StudentsBloc(repository: mockRepository);
    });
    
    tearDown(() {
      studentsBloc.close();
    });
    
    test('initial state should be StudentsInitial', () {
      expect(studentsBloc.state, equals(StudentsInitial()));
    });
    
    blocTest<StudentsBloc, StudentsState>(
      'emits [StudentsLoading, StudentsLoaded] when LoadStudents is added',
      build: () {
        when(mockRepository.getStudents())
            .thenAnswer((_) async => const Right([]));
        return studentsBloc;
      },
      act: (bloc) => bloc.add(LoadStudents()),
      expect: () => [
        StudentsLoading(),
        StudentsLoaded([]),
      ],
    );
  });
}
```

---

## 🔒 Security Architecture

### Security Layers
1. **Authentication**: Firebase Auth with phone verification
2. **Authorization**: Firestore security rules
3. **Data Encryption**: Secure storage for sensitive data
4. **App Lock**: Biometric and PIN protection

### Security Implementation
```dart
class SecurityService {
  final LocalAuthentication localAuth;
  final FlutterSecureStorage secureStorage;
  
  SecurityService({
    required this.localAuth,
    required this.secureStorage,
  });
  
  Future<bool> authenticateWithBiometrics() async {
    try {
      return await localAuth.authenticate(
        localizedReason: 'Authenticate to access the app',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }
  
  Future<void> storeSecureData(String key, String value) async {
    await secureStorage.write(key: key, value: value);
  }
  
  Future<String?> getSecureData(String key) async {
    return await secureStorage.read(key: key);
  }
}
```

---

## 📱 Platform-Specific Architecture

### Multi-Platform Support
The app supports multiple platforms with platform-specific implementations:

#### Android
- **Material Design**: Native Android design patterns
- **Permissions**: Runtime permission handling
- **Background Services**: Background data sync
- **Notifications**: Android notification system

#### iOS
- **Cupertino Design**: Native iOS design patterns
- **Keychain**: Secure data storage
- **Background App Refresh**: Background data updates
- **Push Notifications**: iOS notification system

#### Web
- **Responsive Design**: Adaptive layouts
- **PWA Support**: Progressive Web App features
- **Service Workers**: Offline functionality
- **Web APIs**: Browser-specific features

### Platform Detection
```dart
class PlatformUtils {
  static bool get isAndroid => Platform.isAndroid;
  static bool get isIOS => Platform.isIOS;
  static bool get isWeb => kIsWeb;
  static bool get isDesktop => Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  
  static Widget getPlatformWidget({
    required Widget android,
    required Widget ios,
    Widget? web,
    Widget? desktop,
  }) {
    if (isWeb && web != null) return web;
    if (isDesktop && desktop != null) return desktop;
    if (isAndroid) return android;
    if (isIOS) return ios;
    return android; // Default fallback
  }
}
```

---

## 🚀 Performance Architecture

### Performance Optimization
1. **Lazy Loading**: Load data on demand
2. **Caching**: Intelligent data caching
3. **Image Optimization**: Compressed image handling
4. **Memory Management**: Efficient memory usage
5. **Background Processing**: Off-main-thread operations

### Performance Monitoring
```dart
class PerformanceService {
  static void trackPageView(String pageName) {
    // Track page views for analytics
  }
  
  static void trackUserAction(String action, Map<String, dynamic> parameters) {
    // Track user actions
  }
  
  static void trackError(String error, StackTrace stackTrace) {
    // Track errors for debugging
  }
}
```

---

## 🔄 Data Flow Architecture

### Data Flow Pattern
1. **User Action**: User interacts with UI
2. **Event**: UI triggers BLoC event
3. **BLoC Processing**: BLoC processes business logic
4. **Repository Call**: BLoC calls repository
5. **Data Source**: Repository accesses data source
6. **State Update**: BLoC emits new state
7. **UI Update**: UI reacts to state change

### Example Data Flow
```dart
// 1. User taps "Add Student" button
onPressed: () {
  context.read<StudentsBloc>().add(AddStudent(student));
}

// 2. BLoC processes the event
Future<void> _onAddStudent(AddStudent event, Emitter<StudentsState> emit) async {
  final result = await repository.addStudent(event.student);
  result.fold(
    (failure) => emit(StudentsError(failure.message)),
    (student) => emit(StudentsLoaded([...currentStudents, student])),
  );
}

// 3. Repository calls data source
Future<Either<Failure, Student>> addStudent(Student student) async {
  try {
    final docRef = await firestore
        .collection('teachers')
        .doc(uid)
        .collection('students')
        .add(student.toJson());
    
    return Right(student.copyWith(id: docRef.id));
  } catch (e) {
    return Left(ServerFailure(e.toString()));
  }
}

// 4. UI updates based on new state
BlocBuilder<StudentsBloc, StudentsState>(
  builder: (context, state) {
    if (state is StudentsLoaded) {
      return ListView.builder(
        itemCount: state.students.length,
        itemBuilder: (context, index) => StudentCard(student: state.students[index]),
      );
    }
    return const CircularProgressIndicator();
  },
)
```

---

## 📊 Monitoring & Analytics

### Error Handling
```dart
class ErrorHandler {
  static void handleError(Object error, StackTrace stackTrace) {
    // Log error to console in debug mode
    if (kDebugMode) {
      print('Error: $error');
      print('StackTrace: $stackTrace');
    }
    
    // Send error to crash reporting service
    // FirebaseCrashlytics.instance.recordError(error, stackTrace);
  }
}
```

### Analytics Integration
```dart
class AnalyticsService {
  static void logEvent(String eventName, Map<String, dynamic> parameters) {
    // Log custom events
    // FirebaseAnalytics.instance.logEvent(
    //   name: eventName,
    //   parameters: parameters,
    // );
  }
  
  static void setUserProperty(String name, String value) {
    // Set user properties
    // FirebaseAnalytics.instance.setUserProperty(name: name, value: value);
  }
}
```

---

## 🔧 Development Tools

### Code Generation
```yaml
# pubspec.yaml
dev_dependencies:
  build_runner: ^2.4.7
  freezed: ^2.4.6
  json_annotation: ^4.8.1
  json_serializable: ^6.7.1
```

### Linting & Formatting
```yaml
# analysis_options.yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    - prefer_const_constructors
    - prefer_const_literals_to_create_immutables
    - avoid_print
    - avoid_unnecessary_containers
```

### Build Scripts
```bash
# Generate code
flutter packages pub run build_runner build --delete-conflicting-outputs

# Run tests
flutter test

# Analyze code
flutter analyze

# Format code
dart format lib/
```

---

## 📈 Scalability Considerations

### Horizontal Scaling
- **Microservices**: Break down into smaller services
- **Load Balancing**: Distribute load across multiple instances
- **Caching**: Implement Redis for data caching
- **CDN**: Use CDN for static assets

### Vertical Scaling
- **Database Optimization**: Optimize Firestore queries
- **Memory Management**: Efficient memory usage
- **CPU Optimization**: Background processing
- **Storage Optimization**: Compress and optimize data

### Future Enhancements
- **Multi-tenant Architecture**: Support multiple organizations
- **API Gateway**: Centralized API management
- **Event Sourcing**: Event-driven architecture
- **CQRS**: Command Query Responsibility Segregation

---

**This architecture documentation provides a comprehensive overview of the DarsBook app's technical architecture and implementation patterns.**
