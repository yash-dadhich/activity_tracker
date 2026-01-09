# Phase 2 - Quick Implementation Guide

**What's Been Created So Far:**

## ✅ Completed Components

### 1. Data Models
- `lib/domain/entities/time_entry.dart` - Time tracking entity
- `lib/providers/time_tracking_provider.dart` - Time tracking state management

### 2. Services
- `lib/services/admin_password_service.dart` - Admin password validation (password: 123456)

### 3. UI Components
- `lib/presentation/widgets/admin_password_dialog.dart` - Password dialog
- `lib/presentation/widgets/clock_in_out_widget.dart` - Clock in/out widget

---

## 🚧 What Needs to Be Done

### Priority 1: Backend API (2 hours)
Add these endpoints to `simple_backend.js`:

```javascript
// Time tracking endpoints
POST /v1/time-tracking/clock-in
POST /v1/time-tracking/clock-out
GET /v1/time-tracking/current-session
GET /v1/time-tracking/sessions
GET /v1/time-tracking/summary
```

### Priority 2: Integrate Clock In/Out Widget (1 hour)
Add the widget to employee and manager dashboards

### Priority 3: App Lifecycle Management (3 hours)
- Prevent app closure without admin password
- Handle window close events
- System tray integration

### Priority 4: Screen Permissions (2 hours)
- Request screen recording permission
- Request accessibility permission
- Permission status UI

### Priority 5: Role-Based Reports (4 hours)
- Admin: View all users' reports
- Manager: View team reports
- Employee: View own reports

---

## 📝 Implementation Steps

### Step 1: Add Backend Endpoints

Add to `simple_backend.js`:

```javascript
// Mock time entries storage
const timeEntries = {};
let timeEntryCounter = 1;

// Clock In
if (path === '/v1/time-tracking/clock-in' && req.method === 'POST') {
  const body = await parseBody(req);
  const currentUser = getUserFromToken(req);
  
  if (!currentUser) {
    res.writeHead(401);
    res.end(JSON.stringify({ success: false, error: 'Unauthorized' }));
    return;
  }

  const entryId = `time-${timeEntryCounter++}`;
  const entry = {
    id: entryId,
    userId: currentUser.userId,
    clockInTime: new Date().toISOString(),
    clockOutTime: null,
    duration: null,
    status: 'active',
    location: body.location,
    deviceId: body.deviceInfo?.platform,
    metadata: body.deviceInfo || {}
  };

  timeEntries[entryId] = entry;

  res.writeHead(200);
  res.end(JSON.stringify({
    success: true,
    data: { session: entry }
  }));
  return;
}

// Clock Out
if (path === '/v1/time-tracking/clock-out' && req.method === 'POST') {
  const body = await parseBody(req);
  const entry = timeEntries[body.sessionId];

  if (!entry) {
    res.writeHead(404);
    res.end(JSON.stringify({ success: false, error: 'Session not found' }));
    return;
  }

  const clockOutTime = new Date();
  const clockInTime = new Date(entry.clockInTime);
  const duration = Math.floor((clockOutTime - clockInTime) / 1000);

  entry.clockOutTime = clockOutTime.toISOString();
  entry.duration = duration;
  entry.status = 'completed';

  res.writeHead(200);
  res.end(JSON.stringify({
    success: true,
    data: { session: entry }
  }));
  return;
}

// Get Current Session
if (path === '/v1/time-tracking/current-session' && req.method === 'GET') {
  const currentUser = getUserFromToken(req);
  
  if (!currentUser) {
    res.writeHead(401);
    res.end(JSON.stringify({ success: false, error: 'Unauthorized' }));
    return;
  }

  const activeSession = Object.values(timeEntries).find(
    entry => entry.userId === currentUser.userId && entry.status === 'active'
  );

  res.writeHead(200);
  res.end(JSON.stringify({
    success: true,
    data: {
      session: activeSession || null,
      isMonitoring: activeSession ? true : false
    }
  }));
  return;
}
```

### Step 2: Update Employee Dashboard

Add clock in/out widget to employee dashboard:

```dart
// In lib/presentation/screens/dashboard/employee_dashboard.dart
import '../widgets/clock_in_out_widget.dart';

// Add to dashboard body:
Column(
  children: [
    ClockInOutWidget(),
    // ... rest of dashboard
  ],
)
```

### Step 3: Update Manager Dashboard

Same as employee - add clock in/out widget

### Step 4: Prevent App Closure

Update `lib/main.dart`:

```dart
import 'package:window_manager/window_manager.dart';
import 'services/admin_password_service.dart';
import 'presentation/widgets/admin_password_dialog.dart';

class MyApp extends StatefulWidget with WindowListener {
  @override
  void onWindowClose() async {
    final authManager = context.read<AuthManager>();
    
    // Admin can close without password
    if (authManager.isAdmin || authManager.isSuperAdmin) {
      await windowManager.destroy();
      return;
    }

    // Employees/Managers need admin password
    final confirmed = await AdminPasswordDialog.show(
      context,
      title: 'Stop Monitoring',
      message: 'Enter admin password to stop monitoring and close app:',
    );

    if (confirmed) {
      await windowManager.destroy();
    }
  }
}
```

### Step 5: Add Permission Requests

Create permission service:

```dart
// lib/services/permission_service.dart
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestScreenRecording() async {
    // macOS specific
    final status = await Permission.screenRecording.request();
    return status.isGranted;
  }

  static Future<bool> checkScreenRecording() async {
    final status = await Permission.screenRecording.status;
    return status.isGranted;
  }
}
```

---

## 🎯 Quick Win Implementation (30 minutes)

To get basic functionality working quickly:

1. **Add backend endpoints** (15 min)
2. **Add clock widget to dashboards** (10 min)
3. **Test clock in/out** (5 min)

This gives you working time tracking immediately!

---

## 📋 Full Implementation Checklist

### Backend
- [ ] Add time tracking endpoints to simple_backend.js
- [ ] Add time entries storage
- [ ] Add role-based filtering for reports

### Frontend - Time Tracking
- [ ] Add TimeTrackingProvider to main.dart
- [ ] Add ClockInOutWidget to employee dashboard
- [ ] Add ClockInOutWidget to manager dashboard
- [ ] Test clock in/out functionality

### Frontend - Admin Password
- [ ] Initialize AdminPasswordService in main.dart
- [ ] Add window close handler
- [ ] Test password protection

### Frontend - Permissions
- [ ] Create permission service
- [ ] Add permission request UI
- [ ] Handle permission denials
- [ ] Test permissions

### Frontend - Reports
- [ ] Create reports screen for admin
- [ ] Create reports screen for manager
- [ ] Create reports screen for employee
- [ ] Add role-based filtering

---

## 🚀 Next Actions

1. **Implement backend endpoints** - This is the foundation
2. **Add clock widget to dashboards** - Makes it usable
3. **Test basic flow** - Verify it works
4. **Add admin password protection** - Security
5. **Add permissions** - Full functionality
6. **Add reports** - Complete feature

Would you like me to:
A) Implement the backend endpoints now?
B) Update the dashboards with clock widget?
C) Implement all of the above step by step?

Let me know and I'll continue!
