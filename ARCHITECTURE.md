# Activity Tracker - Architecture Documentation

## System Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        Flutter Application                       │
│                         (Cross-Platform)                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │   Screens    │  │  Providers   │  │   Services   │          │
│  │              │  │              │  │              │          │
│  │ - Home       │  │ - Activity   │  │ - Monitoring │          │
│  │ - Settings   │  │   Provider   │  │ - Permission │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
│         │                  │                  │                  │
│         └──────────────────┴──────────────────┘                  │
│                            │                                     │
│                   ┌────────▼────────┐                           │
│                   │  Method Channel  │                           │
│                   └────────┬────────┘                           │
└────────────────────────────┼─────────────────────────────────────┘
                             │
        ┌────────────────────┴────────────────────┐
        │                                         │
┌───────▼────────┐                       ┌───────▼────────┐
│  Windows (C++)  │                       │  macOS (Swift)  │
├────────────────┤                       ├────────────────┤
│                │                       │                │
│ Win32 API      │                       │ Cocoa          │
│ GDI+           │                       │ Core Graphics  │
│ Hooks          │                       │ Event Tap      │
│                │                       │                │
└────────────────┘                       └────────────────┘
```

## Layer Architecture

### 1. Presentation Layer (Flutter/Dart)

```
lib/
├── screens/              # UI Components
│   ├── home_screen.dart
│   └── settings_screen.dart
│
├── providers/            # State Management
│   └── activity_provider.dart
│
└── models/              # Data Models
    ├── activity_log.dart
    └── monitoring_config.dart
```

**Responsibilities:**
- User interface rendering
- User input handling
- State management
- Navigation

### 2. Business Logic Layer (Flutter/Dart)

```
lib/services/
├── monitoring_service.dart    # Core monitoring logic
└── permission_service.dart    # Permission management
```

**Responsibilities:**
- Coordinate monitoring activities
- Manage permissions
- Handle data processing
- Communicate with native layer

### 3. Platform Layer (Native Code)

#### Windows (C++)
```
windows/runner/
├── monitoring_plugin.cpp
└── monitoring_plugin.h
```

#### macOS (Swift)
```
macos/Runner/
├── MonitoringPlugin.swift
└── PermissionPlugin.swift
```

**Responsibilities:**
- OS-specific API calls
- Screenshot capture
- Window tracking
- Input monitoring
- Idle detection

## Data Flow Architecture

### Monitoring Flow

```
User Action (Start Monitoring)
        │
        ▼
┌───────────────────┐
│  Home Screen      │
│  (Toggle Switch)  │
└────────┬──────────┘
         │
         ▼
┌───────────────────┐
│ Activity Provider │
│ (State Update)    │
└────────┬──────────┘
         │
         ▼
┌───────────────────┐
│ Monitoring Service│
│ (Start Timers)    │
└────────┬──────────┘
         │
         ▼
┌───────────────────┐
│  Method Channel   │
│  (Platform Call)  │
└────────┬──────────┘
         │
    ┌────┴────┐
    │         │
    ▼         ▼
┌────────┐ ┌────────┐
│Windows │ │ macOS  │
│ Plugin │ │ Plugin │
└────┬───┘ └───┬────┘
     │         │
     ▼         ▼
┌─────────────────┐
│   OS APIs       │
│ (Hooks/Events)  │
└─────────────────┘
```

### Screenshot Capture Flow

```
Timer Trigger (Every N seconds)
        │
        ▼
┌──────────────────────┐
│ Monitoring Service   │
│ captureScreenshot()  │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│   Method Channel     │
│ "captureScreenshot"  │
└──────────┬───────────┘
           │
      ┌────┴────┐
      │         │
      ▼         ▼
┌──────────┐ ┌──────────┐
│ Windows  │ │  macOS   │
│ BitBlt   │ │ CGImage  │
└────┬─────┘ └────┬─────┘
     │            │
     ▼            ▼
┌─────────────────────┐
│  Save to File       │
│  (PNG format)       │
└──────────┬──────────┘
           │
           ▼
┌──────────────────────┐
│  Return File Path    │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│  Activity Provider   │
│  (Update UI)         │
└──────────────────────┘
```

### Activity Tracking Flow

```
Periodic Check (Every 5 seconds)
        │
        ▼
┌──────────────────────┐
│ Monitoring Service   │
│ trackActivity()      │
└──────────┬───────────┘
           │
           ├─────────────────────┐
           │                     │
           ▼                     ▼
┌──────────────────┐   ┌──────────────────┐
│ getActiveWindow()│   │ getInputActivity()│
└────────┬─────────┘   └────────┬─────────┘
         │                      │
         ▼                      ▼
┌─────────────────────────────────┐
│      Method Channels            │
└────────┬────────────────────┬───┘
         │                    │
         ▼                    ▼
┌────────────────┐   ┌────────────────┐
│ Get Window     │   │ Get Input      │
│ Title & App    │   │ Counts         │
└────────┬───────┘   └────────┬───────┘
         │                    │
         └──────────┬─────────┘
                    │
                    ▼
         ┌──────────────────┐
         │  Create Activity │
         │  Log Object      │
         └────────┬─────────┘
                  │
                  ▼
         ┌──────────────────┐
         │ Activity Provider│
         │ (Add to List)    │
         └────────┬─────────┘
                  │
                  ▼
         ┌──────────────────┐
         │   Update UI      │
         └──────────────────┘
```

## State Management Architecture

### Provider Pattern

```
┌─────────────────────────────────────────┐
│         Activity Provider               │
├─────────────────────────────────────────┤
│                                         │
│  State:                                 │
│  - isMonitoring: bool                   │
│  - activityLogs: List<ActivityLog>      │
│  - config: MonitoringConfig             │
│  - currentApplication: String           │
│  - todayKeystrokes: int                 │
│  - todayMouseClicks: int                │
│                                         │
│  Methods:                               │
│  - startMonitoring()                    │
│  - stopMonitoring()                     │
│  - addActivityLog()                     │
│  - updateConfig()                       │
│  - incrementKeystrokes()                │
│  - incrementMouseClicks()               │
│                                         │
└─────────────────────────────────────────┘
         │                    │
         │ notifyListeners()  │
         │                    │
    ┌────▼────┐          ┌───▼────┐
    │  Home   │          │Settings│
    │ Screen  │          │ Screen │
    └─────────┘          └────────┘
```

### State Flow

```
User Action
    │
    ▼
┌─────────────┐
│   Widget    │
│ (UI Event)  │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  Provider   │
│ (Update)    │
└──────┬──────┘
       │
       │ notifyListeners()
       │
       ▼
┌─────────────┐
│  Consumer   │
│ (Rebuild)   │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│   Widget    │
│ (Re-render) │
└─────────────┘
```

## Platform Channel Architecture

### Method Channel Communication

```
Flutter (Dart)                    Native (C++/Swift)
─────────────                     ──────────────────

┌──────────────┐                 ┌──────────────┐
│   Service    │                 │    Plugin    │
└──────┬───────┘                 └──────▲───────┘
       │                                │
       │ invokeMethod()                 │
       ├────────────────────────────────┤
       │                                │
       │  Method Name + Arguments       │
       │ ─────────────────────────────> │
       │                                │
       │                                │ Execute
       │                                │ Native Code
       │                                │
       │         Return Result          │
       │ <───────────────────────────── │
       │                                │
       ▼                                │
┌──────────────┐                 ┌──────────────┐
│   Process    │                 │   Return     │
│   Result     │                 │   Value      │
└──────────────┘                 └──────────────┘
```

### Available Method Channels

#### Monitoring Channel
```
Channel: "com.activitytracker/monitoring"

Methods:
├── startMonitoring(config: Map)
├── stopMonitoring()
├── captureScreenshot() → String
├── getActiveWindow() → Map
├── getInputActivity() → Map
└── isSystemIdle(threshold: int) → bool
```

#### Permission Channel (macOS)
```
Channel: "com.activitytracker/permissions"

Methods:
├── checkScreenRecording() → bool
├── checkAccessibility() → bool
├── requestScreenRecording()
├── requestAccessibility()
└── openSystemPreferences()
```

## Native Implementation Architecture

### Windows (C++)

```
MonitoringPlugin
├── Screenshot Capture
│   ├── GetDC() - Get device context
│   ├── CreateCompatibleDC() - Create memory DC
│   ├── BitBlt() - Copy screen to memory
│   └── GDI+ Save to PNG
│
├── Window Tracking
│   ├── GetForegroundWindow() - Get active window
│   ├── GetWindowText() - Get window title
│   └── GetModuleBaseName() - Get process name
│
├── Input Monitoring
│   ├── SetWindowsHookEx(WH_KEYBOARD_LL) - Keyboard hook
│   ├── SetWindowsHookEx(WH_MOUSE_LL) - Mouse hook
│   └── Hook callbacks increment counters
│
└── Idle Detection
    └── GetLastInputInfo() - Get last input time
```

### macOS (Swift)

```
MonitoringPlugin
├── Screenshot Capture
│   ├── CGMainDisplayID() - Get display
│   ├── CGDisplayCreateImage() - Capture screen
│   └── CGImageDestination - Save to PNG
│
├── Window Tracking
│   ├── NSWorkspace.frontmostApplication - Get app
│   └── CGWindowListCopyWindowInfo() - Get window info
│
├── Input Monitoring
│   ├── CGEvent.tapCreate() - Create event tap
│   ├── Event callback for keyDown
│   └── Event callback for mouseDown
│
└── Idle Detection
    └── CGEventSource.secondsSinceLastEventType()

PermissionPlugin
├── Screen Recording
│   ├── CGDisplayCreateImage() - Test permission
│   └── Trigger permission dialog
│
└── Accessibility
    ├── AXIsProcessTrustedWithOptions() - Check
    └── Request with prompt option
```

## Data Model Architecture

### Activity Log Model

```
ActivityLog
├── id: String (UUID)
├── timestamp: DateTime
├── activeWindow: String
├── applicationName: String
├── screenshotPath: String?
├── keystrokes: int
├── mouseClicks: int
└── isIdle: bool

Methods:
├── toJson() → Map<String, dynamic>
└── fromJson(Map) → ActivityLog
```

### Monitoring Config Model

```
MonitoringConfig
├── screenshotEnabled: bool
├── screenshotInterval: int
├── keystrokeTracking: bool
├── mouseTracking: bool
├── applicationTracking: bool
├── idleThreshold: int
├── serverUrl: String
└── apiKey: String

Methods:
├── toJson() → Map<String, dynamic>
├── fromJson(Map) → MonitoringConfig
└── copyWith(...) → MonitoringConfig
```

## Security Architecture

### Data Protection Flow

```
┌──────────────┐
│  Screenshot  │
│   Captured   │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│   Encrypt    │
│  (AES-256)   │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ Store Locally│
└──────┬───────┘
       │
       ▼
┌──────────────┐
│  Upload via  │
│    HTTPS     │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│   Backend    │
│   Server     │
└──────────────┘
```

### Authentication Flow

```
App Start
    │
    ▼
┌──────────────┐
│ Load API Key │
│ from Storage │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│  Decrypt Key │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ Add to HTTP  │
│   Headers    │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│  API Request │
│ with Bearer  │
│    Token     │
└──────────────┘
```

## Deployment Architecture

### Enterprise Deployment

```
┌─────────────────────────────────────────┐
│         MDM Server (Jamf/Intune)        │
└────────────┬────────────────────────────┘
             │
             │ Push Configuration
             │ & Application
             │
    ┌────────┴────────┐
    │                 │
    ▼                 ▼
┌─────────┐      ┌─────────┐
│ Windows │      │  macOS  │
│ Devices │      │ Devices │
└────┬────┘      └────┬────┘
     │                │
     │ Report Data    │
     │                │
     └────────┬───────┘
              │
              ▼
     ┌────────────────┐
     │ Backend Server │
     │  (Analytics)   │
     └────────────────┘
```

## Performance Considerations

### Resource Usage

```
Component              CPU    Memory   Disk I/O
─────────────────────  ─────  ───────  ────────
Flutter UI             1-2%   50MB     Low
Monitoring Service     1-2%   20MB     Low
Screenshot Capture     3-5%   30MB     Medium
Input Hooks           <1%    10MB     None
Total (Idle)          2-3%   110MB    Low
Total (Active)        5-10%  150MB    Medium
```

### Optimization Strategies

1. **Screenshot Capture:**
   - Configurable intervals (default: 5 min)
   - Compress images before storage
   - Batch upload to reduce network calls

2. **Activity Tracking:**
   - Poll every 5 seconds (not real-time)
   - Aggregate data before storage
   - Limit log history (100 items in memory)

3. **Input Monitoring:**
   - Count only, don't log actual keys
   - Reset counters after each read
   - Minimal hook processing

## Scalability Architecture

### Future Backend Integration

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│   Client 1   │────▶│              │────▶│   Database   │
└──────────────┘     │              │     │  (MongoDB)   │
                     │              │     └──────────────┘
┌──────────────┐     │   Backend    │
│   Client 2   │────▶│     API      │     ┌──────────────┐
└──────────────┘     │  (Node.js)   │────▶│   Storage    │
                     │              │     │    (S3)      │
┌──────────────┐     │              │     └──────────────┘
│   Client N   │────▶│              │
└──────────────┘     └──────────────┘     ┌──────────────┐
                                          │   Analytics  │
                                          │  Dashboard   │
                                          └──────────────┘
```

---

This architecture is designed to be:
- **Modular:** Easy to modify individual components
- **Scalable:** Can handle many clients
- **Secure:** Multiple layers of protection
- **Maintainable:** Clear separation of concerns
- **Cross-platform:** Shared logic, platform-specific implementations
