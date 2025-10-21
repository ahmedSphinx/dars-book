# 🔒 Session Management Feature - Usage Guide

## Overview
The app now includes a comprehensive session management system that automatically locks the app after 5 minutes of inactivity, requiring users to re-enter their PIN or use biometric authentication.

## 🚀 How to Use

### 1. **Automatic Behavior (No Action Required)**
The session management works automatically:
- ✅ **Session starts** when you authenticate (PIN/biometric)
- ✅ **Session extends** when you use the app
- ✅ **Session continues** when you leave the app
- ✅ **Session validates** when you return to the app
- ✅ **App locks** after 5 minutes of inactivity

### 2. **Testing the Feature**

#### **Option A: Use the Test Screen**
1. Open the app and go to Dashboard
2. Tap the **Security icon** (🔒) in the top-right corner
3. Use the Session Test screen to:
   - Start a new session
   - Extend current session
   - Check session validity
   - Force session expiration
   - Change timeout duration (1, 5, or 10 minutes)

#### **Option B: Real-World Testing**
1. **Set up authentication** (PIN or biometric) in Settings
2. **Authenticate** to start a session
3. **Wait 5 minutes** without using the app
4. **Return to the app** - it should be locked
5. **Re-authenticate** to unlock

### 3. **Session Warning System**
- **30 seconds before expiry**: Warning banner appears
- **"Extend" button**: Tap to extend session manually
- **Countdown timer**: Shows remaining time

## 🛠️ Developer Usage

### **In Your Code:**

```dart
// Start a session after successful authentication
context.read<AppLockBloc>().add(StartSessionEvent());

// Extend current session
context.read<AppLockBloc>().add(ExtendSessionEvent());

// Check if session is valid
context.read<AppLockBloc>().add(CheckSessionValidityEvent());

// Set custom session timeout (in minutes)
context.read<AppLockBloc>().add(SetSessionTimeoutEvent(10));

// Force session expiration (for testing)
sessionService.forceSessionExpiration();
```

### **Listening to Session Events:**

```dart
BlocListener<AppLockBloc, AppLockState>(
  listener: (context, state) {
    if (state is SessionExpired) {
      // Handle session expiration
      Navigator.pushNamed(context, Routes.appLock);
    } else if (state is SessionActive) {
      // Handle active session
      print('Session active: ${state.remainingSeconds}s remaining');
    }
  },
  child: YourWidget(),
)
```

### **Using Session Service Directly:**

```dart
final sessionService = sl<SessionService>();

// Check session validity
bool isValid = sessionService.isSessionValid();

// Get remaining time
int remainingSeconds = sessionService.getRemainingSessionTime();

// Start session
sessionService.startSession();

// Extend session
sessionService.extendSession();

// Set timeout
await sessionService.setSessionTimeout(5); // 5 minutes
```

## ⚙️ Configuration

### **Default Settings:**
- **Session Timeout**: 5 minutes
- **Warning Threshold**: 30 seconds before expiry
- **Storage**: Secure (encrypted)

### **Customization:**
```dart
// Change session timeout
await sessionService.setSessionTimeout(10); // 10 minutes

// Change warning threshold in SessionTimeoutWarning widget
SessionTimeoutWarning(
  warningThresholdSeconds: 60, // Show warning 1 minute before expiry
  child: YourWidget(),
)
```

## 🔧 Integration Points

### **1. App Lifecycle**
- **Pause**: Session continues running
- **Resume**: Session validity checked
- **Background**: Session timer continues

### **2. Authentication Flow**
- **Login**: Session starts automatically
- **Logout**: Session ends automatically
- **Re-authentication**: Session restarts

### **3. UI Components**
- **Dashboard**: Wrapped with SessionTimeoutWarning
- **All Screens**: Can access session management
- **Settings**: Can configure session timeout

## 🧪 Testing Scenarios

### **Test 1: Basic Session Flow**
1. Authenticate → Session starts
2. Use app for 2 minutes → Session extends
3. Leave app for 6 minutes → Session expires
4. Return to app → App is locked
5. Re-authenticate → Session restarts

### **Test 2: Session Extension**
1. Start session
2. Wait 4 minutes
3. Use app → Session extends to 5 minutes
4. Wait 5 more minutes → Session expires

### **Test 3: Warning System**
1. Start session
2. Wait 4.5 minutes
3. Warning banner appears
4. Tap "Extend" → Session extends
5. Warning disappears

### **Test 4: Custom Timeout**
1. Set timeout to 1 minute
2. Start session
3. Wait 1 minute → Session expires
4. Set timeout to 10 minutes
5. Start session → 10-minute timeout

## 🚨 Troubleshooting

### **Session Not Starting:**
- Check if authentication was successful
- Verify AppLockBloc is properly initialized
- Check console for errors

### **Session Not Extending:**
- Ensure user activity is detected
- Check if SessionTimeoutWarning is properly wrapped
- Verify session service is running

### **App Not Locking:**
- Check session timeout setting
- Verify app lifecycle monitoring
- Check if session timer is running

### **Warning Not Showing:**
- Check warning threshold setting
- Verify SessionTimeoutWarning widget is included
- Check if session is active

## 📱 User Experience

### **For End Users:**
- **Seamless**: Works automatically without user intervention
- **Secure**: Automatic locking after inactivity
- **User-friendly**: Clear warnings and easy re-authentication
- **Configurable**: Can adjust timeout in settings

### **For Developers:**
- **Easy Integration**: Simple API calls
- **Flexible**: Customizable timeout and warning settings
- **Reliable**: Handles edge cases and errors gracefully
- **Testable**: Comprehensive test suite included

## 🔐 Security Features

- **Automatic Locking**: Prevents unauthorized access
- **Secure Storage**: Session data encrypted
- **Biometric Integration**: Works with existing auth
- **PIN Integration**: Works with existing auth
- **Session Persistence**: Survives app restarts

## 📊 Monitoring

### **Session Events:**
- `SessionStarted`: When session begins
- `SessionExtended`: When session is extended
- `SessionEnded`: When session ends manually
- `SessionExpired`: When session times out

### **Session State:**
- `SessionActive`: Session is running with remaining time
- `SessionExpired`: Session has expired
- `AppLocked`: App is locked due to session expiry

## 🎯 Best Practices

1. **Always wrap main screens** with SessionTimeoutWarning
2. **Handle session events** in your BLoC listeners
3. **Test thoroughly** with different timeout settings
4. **Monitor session state** for debugging
5. **Provide user feedback** for session actions

## 📝 Example Implementation

```dart
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SessionTimeoutWarning(
      warningThresholdSeconds: 30,
      child: Scaffold(
        appBar: AppBar(title: Text('My Screen')),
        body: BlocListener<AppLockBloc, AppLockState>(
          listener: (context, state) {
            if (state is SessionExpired) {
              Navigator.pushNamed(context, Routes.appLock);
            }
          },
          child: YourContent(),
        ),
      ),
    );
  }
}
```

This session management system provides enterprise-grade security while maintaining a smooth user experience. Users are automatically protected from unauthorized access while enjoying seamless app usage during active sessions.
