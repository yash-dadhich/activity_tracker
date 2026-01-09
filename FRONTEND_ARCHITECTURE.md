# Frontend Architecture - Flutter Application

**Framework:** Flutter 3.x  
**State Management:** Riverpod 2.x  
**Architecture:** Clean Architecture + Feature-First

---

## 📁 COMPLETE FOLDER STRUCTURE

```
frontend/
├── lib/
│   ├── main.dart                           # App entry point
│   │
│   ├── core/                               # Core functionality
│   │   ├── constants/
│   │   │   ├── app_constants.dart          # App-wide constants
│   │   │   ├── api_constants.dart          # API endpoints
│   │   │   └── asset_constants.dart        # Asset paths
│   │   │
│   │   ├── theme/
│   │   │   ├── app_theme.dart              # Material 3 theme
│   │   │   ├── app_colors.dart             # Color palette
│   │   │   ├── app_typography.dart         # Text styles
│   │   │   └── app_dimensions.dart         # Spacing, sizes
│   │   │
│   │   ├── network/
│   │   │   ├── api_client.dart             # HTTP client (Dio)
│   │   │   ├── socket_client.dart          # Socket.io client
│   │   │   ├── api_interceptor.dart        # Request/response interceptor
│   │   │   └── network_info.dart           # Connectivity check
│   │   │
│   │   ├── storage/
│   │   │   ├── secure_storage.dart         # Encrypted storage
│   │   │   ├── local_storage.dart          # SharedPreferences
│   │   │   └── cache_manager.dart          # Cache management
│   │   │
│   │   ├── error/
│   │   │   ├── failures.dart               # Failure classes
│   │   │   ├── exceptions.dart             # Exception classes
│   │   │   └── error_handler.dart          # Global error handler
│   │   │
│   │   ├── utils/
│   │   │   ├── validators.dart             # Input validators
│   │   │   ├── formatters.dart             # Data formatters
│   │   │   ├── extensions.dart             # Dart extensions
│   │   │   └── helpers.dart                # Helper functions
│   │   │
│   │   └── router/
│   │       ├── app_router.dart             # Route configuration
│   │       └── route_guards.dart           # Auth guards
│   │
│   ├── features/                           # Feature modules
│   │   │
│   │   ├── auth/                           # Authentication
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   │   └── user_model.dart
│   │   │   │   ├── datasources/
│   │   │   │   │   ├── auth_remote_datasource.dart
│   │   │   │   │   └── auth_local_datasource.dart
│   │   │   │   └── repositories/
│   │   │   │       └── auth_repository_impl.dart
│   │   │   │
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── user.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── auth_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── login_usecase.dart
│   │   │   │       ├── logout_usecase.dart
│   │   │   │       └── get_current_user_usecase.dart
│   │   │   │
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── auth_provider.dart
│   │   │       ├── screens/
│   │   │       │   ├── login_screen.dart
│   │   │       │   └── register_screen.dart
│   │   │       └── widgets/
│   │   │           ├── login_form.dart
│   │   │           └── social_login_buttons.dart
│   │   │
│   │   ├── workspace/                      # Workspaces
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │
│   │   ├── chat/                           # Messaging
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │
│   │   ├── calls/                          # Audio/Video
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │
│   │   ├── tasks/                          # Task Management
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │
│   │   └── monitoring/                     # Activity Monitoring
│   │       ├── data/
│   │       ├── domain/
│   │       └── presentation/
│   │
│   └── shared/                             # Shared widgets
│       ├── widgets/
│       │   ├── buttons/
│       │   ├── inputs/
│       │   ├── cards/
│       │   ├── dialogs/
│       │   └── loaders/
│       └── layouts/
│           ├── main_layout.dart
│           └── responsive_layout.dart
│
├── assets/
│   ├── images/
│   ├── icons/
│   ├── fonts/
│   └── animations/
│
├── test/
│   ├── unit/
│   ├── widget/
│   └── integration/
│
└── pubspec.yaml
```

---

## 📦 DEPENDENCIES (pubspec.yaml)

```yaml
name: teamsync_pro
description: Enterprise Communication Platform
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.4.9
  riverpod_annotation: ^2.3.3

  # Network
  dio: ^5.4.0
  socket_io_client: ^2.0.3
  connectivity_plus: ^5.0.2

  # WebRTC
  flutter_webrtc: ^0.9.48

  # Storage
  flutter_secure_storage: ^9.0.0
  shared_preferences: ^2.2.2
  hive: ^2.2.3
  hive_flutter: ^1.1.0

  # UI
  go_router: ^13.0.0
  flutter_svg: ^2.0.9
  cached_network_image: ^3.3.1
  shimmer: ^3.0.0
  lottie: ^3.0.0

  # Utils
  intl: ^0.19.0
  uuid: ^4.3.3
  path_provider: ^2.1.2
  url_launcher: ^6.2.4
  file_picker: ^6.1.1
  image_picker: ^1.0.7

  # Desktop
  window_manager: ^0.3.8
  tray_manager: ^0.2.2
  screen_retriever: ^0.1.9

  # Monitoring
  screenshot: ^2.1.0
  device_info_plus: ^9.1.1
  package_info_plus: ^5.0.1

  # Notifications
  flutter_local_notifications: ^16.3.2

  # Code Generation
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  
  # Code Generation
  build_runner: ^2.4.7
  freezed: ^2.4.6
  json_serializable: ^6.7.1
  riverpod_generator: ^2.3.9
  riverpod_lint: ^2.3.7

  # Testing
  mockito: ^5.4.4
  mocktail: ^1.0.2

flutter:
  uses-material-design: true
  
  assets:
    - assets/images/
    - assets/icons/
    - assets/animations/
  
  fonts:
    - family: Inter
      fonts:
        - asset: assets/fonts/Inter-Regular.ttf
        - asset: assets/fonts/Inter-Medium.ttf
          weight: 500
        - asset: assets/fonts/Inter-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/Inter-Bold.ttf
          weight: 700
```

---

## 🎨 DESIGN SYSTEM

See `DESIGN_SYSTEM.md` for complete details.

### Color Palette
```dart
// Primary: Professional Blue
primary: Color(0xFF2563EB),        // Blue 600
primaryLight: Color(0xFF3B82F6),   // Blue 500
primaryDark: Color(0xFF1E40AF),    // Blue 700

// Secondary: Purple Accent
secondary: Color(0xFF7C3AED),      // Purple 600
secondaryLight: Color(0xFF8B5CF6), // Purple 500
secondaryDark: Color(0xFF6D28D9),  // Purple 700

// Neutral
background: Color(0xFFF8FAFC),     // Slate 50
surface: Color(0xFFFFFFFF),        // White
surfaceVariant: Color(0xFFF1F5F9), // Slate 100

// Text
textPrimary: Color(0xFF0F172A),    // Slate 900
textSecondary: Color(0xFF475569),  // Slate 600
textTertiary: Color(0xFF94A3B8),   // Slate 400

// Status
success: Color(0xFF10B981),        // Green 500
warning: Color(0xFFF59E0B),        // Amber 500
error: Color(0xFFEF4444),          // Red 500
info: Color(0xFF3B82F6),           // Blue 500
```

---

## 🔄 STATE MANAGEMENT (Riverpod)

### Provider Types

1. **Provider** - Immutable data
2. **StateProvider** - Simple state
3. **StateNotifierProvider** - Complex state
4. **FutureProvider** - Async data
5. **StreamProvider** - Real-time data

### Example: Auth Provider

```dart
// auth_provider.dart
@riverpod
class Auth extends _$Auth {
  @override
  FutureOr<User?> build() async {
    return await _getCurrentUser();
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final user = await ref.read(authRepositoryProvider)
          .login(email, password);
      return user;
    });
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncValue.data(null);
  }
}
```

---

## 🧩 CLEAN ARCHITECTURE LAYERS

### 1. Presentation Layer
- **Screens** - Full page views
- **Widgets** - Reusable UI components
- **Providers** - State management (Riverpod)

### 2. Domain Layer
- **Entities** - Business objects
- **Repositories** - Abstract interfaces
- **Use Cases** - Business logic

### 3. Data Layer
- **Models** - Data transfer objects
- **Data Sources** - API, Database, Cache
- **Repository Implementations** - Concrete implementations

---

## 📱 SCREEN EXAMPLES

See `IMPLEMENTATION_GUIDE.md` for complete code.

### Main Layout (Slack-like)
```
┌─────────────────────────────────────────────────────┐
│  [Logo] TeamSync Pro              [@User] [Settings] │
├──────────┬──────────────┬──────────────────────────┤
│          │              │                           │
│ Workspace│   Channels   │    Message Thread        │
│ Sidebar  │   Sidebar    │                          │
│          │              │                           │
│ • Acme   │ # general    │  [Messages]              │
│ • Tech   │ # dev-team   │  [Input]                 │
│          │              │                           │
│ + New    │ DMs          │                           │
│          │ • John       │                           │
│          │ • Jane       │                           │
└──────────┴──────────────┴──────────────────────────┘
```

---

## 🧪 TESTING STRATEGY

### Unit Tests
- Test business logic
- Test use cases
- Test providers

### Widget Tests
- Test UI components
- Test user interactions
- Test state changes

### Integration Tests
- Test complete flows
- Test API integration
- Test real-time features

---

**Next:** Read `BACKEND_ARCHITECTURE.md` for backend structure!
