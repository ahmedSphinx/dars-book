# DarsBook - API Documentation

## 🔥 Firebase Integration Overview

DarsBook uses Firebase as its backend infrastructure, providing a comprehensive set of services for authentication, data storage, cloud functions, and file storage.

### Firebase Services Used
- **Firebase Authentication** - Phone number authentication
- **Cloud Firestore** - NoSQL document database
- **Cloud Functions** - Server-side business logic
- **Firebase Storage** - File storage (future feature)
- **Firebase Cloud Messaging** - Push notifications (future feature)

---

## 📊 Database Schema

### Firestore Collections Structure

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

---

## 🔐 Authentication API

### Firebase Authentication

#### Phone Number Authentication
```dart
// Send OTP to phone number
Future<void> sendOTP(String phoneNumber) async {
  await FirebaseAuth.instance.verifyPhoneNumber(
    phoneNumber: phoneNumber,
    verificationCompleted: (PhoneAuthCredential credential) async {
      await FirebaseAuth.instance.signInWithCredential(credential);
    },
    verificationFailed: (FirebaseAuthException e) {
      // Handle error
    },
    codeSent: (String verificationId, int? resendToken) {
      // Store verification ID
    },
    codeAutoRetrievalTimeout: (String verificationId) {
      // Handle timeout
    },
  );
}

// Verify OTP
Future<UserCredential> verifyOTP(String verificationId, String otp) async {
  PhoneAuthCredential credential = PhoneAuthProvider.credential(
    verificationId: verificationId,
    smsCode: otp,
  );
  return await FirebaseAuth.instance.signInWithCredential(credential);
}
```

#### Authentication States
- `AuthInitial` - Initial state
- `AuthLoading` - Authentication in progress
- `AuthAuthenticated` - User successfully authenticated
- `AuthUnauthenticated` - User not authenticated
- `AuthError` - Authentication error

---

## 📚 Data Models

### Student Model
```dart
class Student {
  final String id;
  final String name;
  final String? phone;
  final String year;
  final String? notes;
  final bool isActive;
  final double? customLessonPrice;
  final double? customBookletPrice;
  final StudentAggregates aggregates;
}

class StudentAggregates {
  final int sessionsCount;
  final int bookletsCount;
  final double totalCharges;
  final double totalPaid;
  final double remaining;
}
```

### Session Model
```dart
class Session {
  final String id;
  final DateTime dateTime;
  final bool hasBooklet;
  final String? note;
  final List<Attendance> attendances;
}

class Attendance {
  final String studentId;
  final String studentName;
  final bool present;
  final double lessonPriceSnap;
  final double bookletPriceSnap;
  final double sessionCharge;
  final double bookletCharge;
}
```

### Payment Model
```dart
class Payment {
  final String id;
  final String studentId;
  final double amount;
  final PaymentMethod method;
  final String? note;
  final DateTime createdAt;
}

enum PaymentMethod {
  cash,
  transfer,
  wallet,
}
```

### Teacher Model
```dart
class Teacher {
  final String uid;
  final String name;
  final String phone;
  final String? email;
  final List<String> subjects;
  final bool isProfileComplete;
  final DateTime createdAt;
}
```

### Subscription Model
```dart
class Subscription {
  final String tier;
  final DateTime expiresAt;
  final bool isActive;
  final int? graceDays;
}
```

---

## 🗄️ Firestore API

### Collection Access Patterns

#### Teachers Collection
```dart
// Get teacher profile
DocumentSnapshot teacherDoc = await FirebaseFirestore.instance
    .collection('teachers')
    .doc(uid)
    .get();

// Update teacher profile
await FirebaseFirestore.instance
    .collection('teachers')
    .doc(uid)
    .update({
      'name': name,
      'phone': phone,
      'subjects': subjects,
      'isProfileComplete': true,
    });
```

#### Students Subcollection
```dart
// Get all students for a teacher
QuerySnapshot studentsSnapshot = await FirebaseFirestore.instance
    .collection('teachers')
    .doc(uid)
    .collection('students')
    .get();

// Add new student
await FirebaseFirestore.instance
    .collection('teachers')
    .doc(uid)
    .collection('students')
    .add({
      'name': studentName,
      'phone': phone,
      'year': academicYear,
      'notes': notes,
      'isActive': true,
      'customLessonPrice': customPrice,
      'customBookletPrice': customBookletPrice,
      'ownerId': uid,
      'createdAt': FieldValue.serverTimestamp(),
    });

// Update student
await FirebaseFirestore.instance
    .collection('teachers')
    .doc(uid)
    .collection('students')
    .doc(studentId)
    .update(updateData);

// Delete student (soft delete)
await FirebaseFirestore.instance
    .collection('teachers')
    .doc(uid)
    .collection('students')
    .doc(studentId)
    .update({'isActive': false});
```

#### Sessions Subcollection
```dart
// Create new session
await FirebaseFirestore.instance
    .collection('teachers')
    .doc(uid)
    .collection('sessions')
    .add({
      'dateTime': Timestamp.fromDate(sessionDateTime),
      'hasBooklet': hasBooklet,
      'note': sessionNote,
      'ownerId': uid,
      'createdAt': FieldValue.serverTimestamp(),
    });

// Add attendance to session
await FirebaseFirestore.instance
    .collection('teachers')
    .doc(uid)
    .collection('sessions')
    .doc(sessionId)
    .collection('attendances')
    .doc(studentId)
    .set({
      'studentName': studentName,
      'present': isPresent,
      'lessonPriceSnap': lessonPrice,
      'bookletPriceSnap': bookletPrice,
      'sessionCharge': sessionCharge,
      'bookletCharge': bookletCharge,
      'ownerId': uid,
    });
```

#### Payments Subcollection
```dart
// Record payment
await FirebaseFirestore.instance
    .collection('teachers')
    .doc(uid)
    .collection('payments')
    .add({
      'studentId': studentId,
      'amount': paymentAmount,
      'method': paymentMethod.toString(),
      'note': paymentNote,
      'ownerId': uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
```

#### Pricing Subcollection
```dart
// Set academic year pricing
await FirebaseFirestore.instance
    .collection('teachers')
    .doc(uid)
    .collection('prices')
    .doc(academicYear)
    .set({
      'lessonPrice': lessonPrice,
      'bookletPrice': bookletPrice,
      'year': academicYear,
      'ownerId': uid,
      'updatedAt': FieldValue.serverTimestamp(),
    });
```

---

## ☁️ Cloud Functions API

### Voucher Redemption
```dart
// Call cloud function to redeem voucher
final HttpsCallable redeemVoucher = FirebaseFunctions.instance
    .httpsCallable('redeemVoucher');

try {
  final result = await redeemVoucher.call({
    'voucherCode': voucherCode,
    'teacherId': uid,
  });
  
  if (result.data['success']) {
    // Voucher redeemed successfully
    final subscription = SubscriptionModel.fromJson(result.data['subscription']);
    return Right(subscription);
  } else {
    return Left(ServerFailure(result.data['error']));
  }
} catch (e) {
  return Left(ServerFailure(e.toString()));
}
```

### Data Aggregation
```dart
// Call cloud function for data aggregation
final HttpsCallable aggregateData = FirebaseFunctions.instance
    .httpsCallable('aggregateData');

try {
  final result = await aggregateData.call({
    'teacherId': uid,
    'dateRange': {
      'start': startDate.toIso8601String(),
      'end': endDate.toIso8601String(),
    },
  });
  
  return Right(result.data);
} catch (e) {
  return Left(ServerFailure(e.toString()));
}
```

---

## 🔒 Security Rules

### Firestore Security Rules
```javascript
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
      
      // Prices subcollection
      match /prices/{yearId} {
        allow read, write: if isAuthenticated() && 
                              resource.data.ownerId == request.auth.uid;
      }
      
      // Sessions subcollection
      match /sessions/{sessionId} {
        allow read, write: if isAuthenticated() && 
                              resource.data.ownerId == request.auth.uid;
        
        // Attendances subcollection
        match /attendances/{attendanceId} {
          allow read, write: if isAuthenticated() && 
                                resource.data.ownerId == request.auth.uid;
        }
      }
      
      // Session templates subcollection
      match /session_templates/{templateId} {
        allow read, write: if isAuthenticated() && 
                              resource.data.ownerId == request.auth.uid;
      }
      
      // Payments subcollection
      match /payments/{paymentId} {
        allow read, write: if isAuthenticated() && 
                              resource.data.ownerId == request.auth.uid;
      }
      
      // Metrics subcollections (read-only for users)
      match /metrics_daily/{dateId} {
        allow read: if isAuthenticated() && 
                       resource.data.ownerId == request.auth.uid;
        allow write: if false; // Only cloud functions can write
      }
      
      match /metrics_monthly/{monthId} {
        allow read: if isAuthenticated() && 
                       resource.data.ownerId == request.auth.uid;
        allow write: if false; // Only cloud functions can write
      }
    }
    
    // Vouchers collection (admin/functions only)
    match /vouchers/{voucherId} {
      allow read, write: if false; // Only cloud functions can access
    }
  }
}
```

---

## 📱 Repository Pattern

### Abstract Repository Interfaces

#### AuthRepository
```dart
abstract class AuthRepository {
  Future<Either<Failure, User>> getCurrentUser();
  Future<Either<Failure, User>> signInWithPhone(String phoneNumber);
  Future<Either<Failure, User>> verifyOTP(String verificationId, String otp);
  Future<Either<Failure, void>> signOut();
  Stream<User?> get authStateChanges;
}
```

#### StudentRepository
```dart
abstract class StudentRepository {
  Future<Either<Failure, List<Student>>> getStudents();
  Future<Either<Failure, Student>> getStudent(String id);
  Future<Either<Failure, Student>> addStudent(Student student);
  Future<Either<Failure, Student>> updateStudent(Student student);
  Future<Either<Failure, void>> deleteStudent(String id);
  Stream<List<Student>> watchStudents();
}
```

#### SessionRepository
```dart
abstract class SessionRepository {
  Future<Either<Failure, List<Session>>> getSessions();
  Future<Either<Failure, Session>> getSession(String id);
  Future<Either<Failure, Session>> createSession(Session session);
  Future<Either<Failure, Session>> updateSession(Session session);
  Future<Either<Failure, void>> deleteSession(String id);
  Future<Either<Failure, void>> markAttendance(String sessionId, Attendance attendance);
  Stream<List<Session>> watchSessions();
}
```

#### PaymentRepository
```dart
abstract class PaymentRepository {
  Future<Either<Failure, List<Payment>>> getPayments();
  Future<Either<Failure, List<Payment>>> getPaymentsByStudent(String studentId);
  Future<Either<Failure, Payment>> recordPayment(Payment payment);
  Future<Either<Failure, Payment>> updatePayment(Payment payment);
  Future<Either<Failure, void>> deletePayment(String id);
  Stream<List<Payment>> watchPayments();
}
```

#### ReportRepository
```dart
abstract class ReportRepository {
  Future<Either<Failure, DashboardSummary>> getDashboardSummary(
    DateTime startDate,
    DateTime endDate,
  );
  Future<Either<Failure, List<StudentReport>>> getStudentReports(
    DateTime startDate,
    DateTime endDate,
  );
  Future<Either<Failure, YearReport>> getYearReport(int year);
  Future<Either<Failure, List<Payment>>> getCollections(
    DateTime startDate,
    DateTime endDate,
  );
}
```

---

## 🔄 Data Synchronization

### Offline Support
```dart
// Enable offline persistence
await FirebaseFirestore.instance.enablePersistence();

// Listen to real-time updates
Stream<QuerySnapshot> studentsStream = FirebaseFirestore.instance
    .collection('teachers')
    .doc(uid)
    .collection('students')
    .snapshots();

studentsStream.listen((QuerySnapshot snapshot) {
  // Handle real-time updates
  for (DocumentChange change in snapshot.docChanges) {
    switch (change.type) {
      case DocumentChangeType.added:
        // Handle new student
        break;
      case DocumentChangeType.modified:
        // Handle updated student
        break;
      case DocumentChangeType.removed:
        // Handle deleted student
        break;
    }
  }
});
```

### Batch Operations
```dart
// Batch write operations
WriteBatch batch = FirebaseFirestore.instance.batch();

// Add multiple operations to batch
batch.set(
  FirebaseFirestore.instance
      .collection('teachers')
      .doc(uid)
      .collection('students')
      .doc(),
  studentData,
);

batch.update(
  FirebaseFirestore.instance
      .collection('teachers')
      .doc(uid)
      .collection('sessions')
      .doc(sessionId),
  sessionData,
);

// Commit batch
await batch.commit();
```

---

## 📊 Analytics & Metrics

### Daily Metrics
```dart
// Daily metrics structure
class DailyMetrics {
  final DateTime date;
  final int sessionsCount;
  final int studentsCount;
  final double totalRevenue;
  final double lessonsRevenue;
  final double bookletsRevenue;
  final int overdueStudentsCount;
}
```

### Monthly Metrics
```dart
// Monthly metrics structure
class MonthlyMetrics {
  final int year;
  final int month;
  final int totalSessions;
  final int totalStudents;
  final double totalRevenue;
  final double averageSessionValue;
  final Map<String, double> revenueByMonth;
}
```

---

## 🚨 Error Handling

### Custom Error Types
```dart
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);
  
  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}
```

### Error Handling Pattern
```dart
Future<Either<Failure, List<Student>>> getStudents() async {
  try {
    final students = await _getStudentsFromFirestore();
    return Right(students);
  } on FirebaseException catch (e) {
    return Left(ServerFailure(e.message ?? 'Unknown Firebase error'));
  } catch (e) {
    return Left(ServerFailure('Unexpected error: $e'));
  }
}
```

---

## 🔧 Configuration

### Firebase Configuration
```dart
// Firebase options (generated by flutterfire)
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
}
```

### Environment Configuration
```dart
class AppConstants {
  static const String appName = 'DarsBook';
  static const String appVersion = '1.0.0';
  static const String firebaseProjectId = 'darsbook-fdf81';
  static const bool isDebugMode = kDebugMode;
}
```

---

## 📈 Performance Optimization

### Query Optimization
```dart
// Use indexes for better performance
Query studentsQuery = FirebaseFirestore.instance
    .collection('teachers')
    .doc(uid)
    .collection('students')
    .where('isActive', isEqualTo: true)
    .orderBy('name')
    .limit(20);

// Use pagination for large datasets
Query paginatedQuery = studentsQuery.startAfterDocument(lastDocument);
```

### Caching Strategy
```dart
// Implement local caching
class LocalCache {
  static final Map<String, dynamic> _cache = {};
  
  static void set(String key, dynamic value) {
    _cache[key] = value;
  }
  
  static T? get<T>(String key) {
    return _cache[key] as T?;
  }
  
  static void clear() {
    _cache.clear();
  }
}
```

---

## 🧪 Testing

### Unit Testing
```dart
// Mock Firebase for testing
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockCollectionReference extends Mock implements CollectionReference {}
class MockDocumentReference extends Mock implements DocumentReference {}

// Test repository implementation
void main() {
  group('StudentRepository', () {
    late StudentRepository repository;
    late MockFirebaseFirestore mockFirestore;
    
    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      repository = StudentRepositoryImpl(firestore: mockFirestore);
    });
    
    test('should return students when getStudents is called', () async {
      // Arrange
      when(mockFirestore.collection(any)).thenReturn(mockCollectionReference);
      
      // Act
      final result = await repository.getStudents();
      
      // Assert
      expect(result, isA<Right<Failure, List<Student>>>());
    });
  });
}
```

---

## 📝 API Best Practices

### 1. Error Handling
- Always wrap Firebase operations in try-catch blocks
- Use Either pattern for consistent error handling
- Provide meaningful error messages to users

### 2. Data Validation
- Validate data before sending to Firebase
- Use Firestore security rules for server-side validation
- Implement client-side validation for better UX

### 3. Performance
- Use pagination for large datasets
- Implement proper indexing in Firestore
- Cache frequently accessed data locally

### 4. Security
- Never expose sensitive data in client code
- Use Firestore security rules for data access control
- Implement proper authentication checks

### 5. Offline Support
- Enable Firestore offline persistence
- Handle offline/online state changes
- Implement proper data synchronization

---

**This API documentation is continuously updated to reflect the latest implementation and best practices.**
