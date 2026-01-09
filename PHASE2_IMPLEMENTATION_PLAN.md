# Phase 2 Implementation Plan - Time Tracking & Monitoring

**Date:** January 7, 2026  
**Status:** 🚧 IN PROGRESS

---

## 🎯 Objectives

### 1. Time Tracking System
- Clock In/Clock Out functionality
- Track work sessions
- Calculate work hours
- Store time entries

### 2. Persistent Monitoring
- Always-running background service
- Cannot be closed by employees/managers
- Admin password required to stop (123456)
- Auto-start on login

### 3. Screen Sharing & Permissions
- Request screen recording permission
- Request screenshot permission
- Handle permission denials
- Guide users through permission setup

### 4. Role-Based Reporting
- Admin: View all users' reports
- Manager: View team members' reports
- Employee: View only own reports

---

## 📋 Implementation Tasks

### Task 1: Clock In/Clock Out System (4 hours)

#### A. Backend API Endpoints
- [ ] `POST /v1/time-tracking/clock-in` - Start work session
- [ ] `POST /v1/time-tracking/clock-out` - End work session
- [ ] `GET /v1/time-tracking/sessions` - Get time entries
- [ ] `GET /v1/time-tracking/current-session` - Get active session
- [ ] `GET /v1/time-tracking/summary` - Get work hours summary

#### B. Frontend Components
- [ ] Clock In/Out button component
- [ ] Current session display
- [ ] Work hours summary widget
- [ ] Time tracking provider

#### C. Data Models
- [ ] TimeEntry entity
- [ ] WorkSession entity
- [ ] TimeTrackingProvider

---

### Task 2: Persistent Monitoring Service (6 hours)

#### A. Background Service
- [ ] Create persistent monitoring service
- [ ] Auto-start on app launch
- [ ] Run in background
- [ ] Survive app minimize

#### B. Admin Password Protection
- [ ] Password dialog component
- [ ] Validate admin password (123456)
- [ ] Prevent app closure without password
- [ ] Intercept quit attempts

#### C. macOS Integration
- [ ] Launch agent for auto-start
- [ ] System tray integration
- [ ] Prevent force quit (where possible)
- [ ] Background execution permissions

---

### Task 3: Screen Permissions (3 hours)

#### A. Permission Requests
- [ ] Screen recording permission
- [ ] Screenshot permission
- [ ] Accessibility permission
- [ ] Camera permission (if needed)

#### B. Permission UI
- [ ] Permission request dialog
- [ ] Permission status display
- [ ] Guide to System Preferences
- [ ] Permission troubleshooting

#### C. Permission Handling
- [ ] Check permission status
- [ ] Request permissions
- [ ] Handle denials
- [ ] Retry mechanism

---

### Task 4: Role-Based Reporting (5 hours)

#### A. Report Screens
- [ ] Admin reports screen (all users)
- [ ] Manager reports screen (team only)
- [ ] Employee reports screen (self only)
- [ ] Report filters and date ranges

#### B. Report Components
- [ ] Activity timeline
- [ ] Screenshots gallery
- [ ] Productivity charts
- [ ] Work hours summary
- [ ] Application usage breakdown

#### C. Backend Filtering
- [ ] Filter reports by organizationId
- [ ] Filter reports by departmentId (managers)
- [ ] Filter reports by userId (employees)
- [ ] Aggregate statistics

---

## 🏗️ Architecture

### Clock In/Clock Out Flow
```
Employee Dashboard
    ↓
Clock In Button
    ↓
POST /v1/time-tracking/clock-in
    ↓
Start Monitoring Service
    ↓
Track Activities
    ↓
Clock Out Button
    ↓
POST /v1/time-tracking/clock-out
    ↓
Stop Monitoring (but keep app running)
```

### Admin Password Protection Flow
```
User Clicks "Quit App"
    ↓
Intercept Quit Event
    ↓
Show Password Dialog
    ↓
User Enters Password
    ↓
Validate Password
    ↓
If Valid: Allow Quit
If Invalid: Deny Quit
```

### Permission Request Flow
```
App Launch
    ↓
Check Permissions
    ↓
If Missing: Show Permission Dialog
    ↓
Guide User to System Preferences
    ↓
Wait for Permission Grant
    ↓
Verify Permissions
    ↓
Start Monitoring
```

---

## 📊 Data Models

### TimeEntry
```dart
class TimeEntry {
  final String id;
  final String userId;
  final DateTime clockInTime;
  final DateTime? clockOutTime;
  final Duration? duration;
  final String status; // 'active', 'completed'
  final String? location;
  final Map<String, dynamic> metadata;
}
```

### WorkSession
```dart
class WorkSession {
  final String id;
  final String userId;
  final DateTime startTime;
  final DateTime? endTime;
  final List<Activity> activities;
  final List<Screenshot> screenshots;
  final Duration totalDuration;
  final Duration productiveDuration;
  final double productivityScore;
}
```

---

## 🔐 Security Considerations

### Admin Password
- Stored securely (hashed)
- Required for:
  - Stopping monitoring
  - Closing app
  - Changing settings
  - Uninstalling app

### Permissions
- Request only necessary permissions
- Explain why each permission is needed
- Handle permission denials gracefully
- Provide clear instructions

### Data Privacy
- Encrypt screenshots
- Secure activity logs
- GDPR compliance
- User consent required

---

## 🎨 UI Components

### Clock In/Out Widget
```
┌─────────────────────────────────┐
│  ⏰ Work Session                │
│                                 │
│  Status: Clocked In             │
│  Started: 9:00 AM               │
│  Duration: 2h 34m               │
│                                 │
│  [Clock Out]                    │
└─────────────────────────────────┘
```

### Admin Password Dialog
```
┌─────────────────────────────────┐
│  🔒 Admin Password Required     │
│                                 │
│  Enter admin password to        │
│  stop monitoring:               │
│                                 │
│  [__________]                   │
│                                 │
│  [Cancel]  [Confirm]            │
└─────────────────────────────────┘
```

### Permission Request Dialog
```
┌─────────────────────────────────┐
│  🔐 Permissions Required        │
│                                 │
│  This app needs:                │
│  ✅ Screen Recording            │
│  ✅ Accessibility               │
│  ❌ Screenshots                 │
│                                 │
│  [Open System Preferences]      │
└─────────────────────────────────┘
```

---

## 📱 User Experience

### Employee Flow
1. Login to app
2. See dashboard with Clock In button
3. Click "Clock In"
4. Monitoring starts automatically
5. Work normally
6. Click "Clock Out" when done
7. Monitoring pauses (app stays running)
8. Cannot close app without admin password

### Manager Flow
1. Login to app
2. Clock In/Out like employee
3. View team reports
4. Monitor team activities
5. Cannot close app without admin password

### Admin Flow
1. Login to app
2. View all reports
3. Manage users
4. Can close app anytime
5. Can stop monitoring for others

---

## 🚀 Implementation Priority

### Phase 2.1 - Core Time Tracking (Week 1)
1. Clock In/Out backend API
2. Clock In/Out UI components
3. Time tracking provider
4. Basic reporting

### Phase 2.2 - Persistent Monitoring (Week 2)
1. Background service
2. Admin password protection
3. Auto-start on login
4. Prevent closure

### Phase 2.3 - Permissions & Reporting (Week 3)
1. Screen permissions
2. Permission UI
3. Role-based reports
4. Report filtering

---

## ✅ Success Criteria

### Time Tracking
- [ ] Employees can clock in/out
- [ ] Work hours are tracked accurately
- [ ] Sessions are stored in database
- [ ] Reports show work hours

### Persistent Monitoring
- [ ] App runs continuously
- [ ] Cannot be closed without password
- [ ] Auto-starts on login
- [ ] Survives system restart

### Permissions
- [ ] All permissions requested
- [ ] Clear permission instructions
- [ ] Graceful handling of denials
- [ ] Permission status visible

### Reporting
- [ ] Admin sees all reports
- [ ] Manager sees team reports
- [ ] Employee sees own reports
- [ ] Reports are accurate

---

## 📝 Notes

### Technical Challenges
1. **macOS App Closure Prevention**
   - Cannot truly prevent force quit
   - Can intercept normal quit attempts
   - Can show warning dialogs
   - Can make it difficult to quit

2. **Background Execution**
   - macOS limits background apps
   - Need proper entitlements
   - May need to keep window hidden
   - System tray integration helps

3. **Permission Persistence**
   - Permissions can be revoked
   - Need to check on each launch
   - Need to handle revocation gracefully
   - Need to re-request if needed

### Future Enhancements
- Biometric authentication
- Geofencing for clock in/out
- Offline time tracking
- Mobile app integration
- Break time tracking
- Overtime calculations

---

**Status:** 🚧 Ready to implement  
**Estimated Time:** 18-20 hours  
**Priority:** High  
**Complexity:** High
