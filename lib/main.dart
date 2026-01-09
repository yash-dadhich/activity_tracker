import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'presentation/screens/dashboard/role_based_dashboard.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'screens/settings_screen.dart';
import 'services/monitoring_service.dart';
import 'services/permission_service.dart';
import 'services/admin_password_service.dart';
import 'services/system_tray_service.dart';
import 'providers/activity_provider.dart';
import 'providers/team_provider.dart';
import 'providers/admin_provider.dart';
import 'providers/super_admin_provider.dart';
import 'providers/organization_provider.dart';
import 'providers/user_management_provider.dart';
import 'providers/time_tracking_provider.dart';
import 'core/auth/auth_manager.dart';
import 'core/network/api_client.dart';
import 'core/storage/secure_storage.dart';
import 'core/constants/app_constants.dart';
import 'presentation/widgets/admin_password_dialog.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize admin password service
  AdminPasswordService.initialize();
  
  // Initialize system tray
  await SystemTrayService().initialize();
  
  // Initialize window manager for desktop
  await windowManager.ensureInitialized();
  
  WindowOptions windowOptions = const WindowOptions(
    size: Size(1200, 800),
    minimumSize: Size(800, 600),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
    title: AppConstants.appName,
    // Prevent window from being closed easily
    alwaysOnTop: false,
  );
  
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
    // Prevent close without confirmation
    await windowManager.setPreventClose(true);
  });
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WindowListener {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Delay adding window listener until after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      windowManager.addListener(this);
      setState(() {
        _isInitialized = true;
      });
    });
    _configureWindow();
  }

  Future<void> _configureWindow() async {
    // Prevent window from being minimizable for employees/managers
    // This will be checked dynamically based on user role
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  Future<void> onWindowClose() async {
    // This is called when user tries to close the window
    // We handle it manually in _handleCloseAttempt
    await _handleCloseAttempt();
  }

  @override
  Future<void> onWindowEvent(String eventName) async {
    // Handle various window events
    if (eventName == 'close') {
      await _handleCloseAttempt();
    }
  }

  Future<void> _handleCloseAttempt() async {
    // Don't handle close attempts until app is fully initialized
    if (!_isInitialized) {
      // Prevent close during initialization
      return;
    }

    // Get the current context from navigator
    final context = navigatorKey.currentContext;
    if (context == null || !mounted) {
      // If no context or widget not mounted, allow close (app not fully initialized)
      await windowManager.destroy();
      return;
    }

    try {
      // Check if user is authenticated and their role
      final authManager = context.read<AuthManager>();
      
      // Admin and Super Admin can close without password
      if (authManager.isAdmin || authManager.isSuperAdmin) {
        await windowManager.destroy();
        return;
      }

      // For employees and managers, ALWAYS require password
      if (authManager.isAuthenticated) {
        // Check if user is clocked in
        final timeTrackingProvider = context.read<TimeTrackingProvider>();
        final isClockedIn = timeTrackingProvider.isClockedIn;
        
        String message = 'Enter admin password to stop monitoring and close app:';
        if (isClockedIn) {
          message = 'You are currently clocked in!\n\nEnter admin password to clock out and close app:';
        }

        final confirmed = await AdminPasswordDialog.show(
          context,
          title: '🔒 Admin Password Required',
          message: message,
        );

        if (confirmed) {
          // If clocked in, clock out first
          if (isClockedIn) {
            await timeTrackingProvider.clockOut();
          }
          await windowManager.destroy();
        } else {
          // User cancelled - keep app running
          // Optionally minimize to tray instead
          await windowManager.minimize();
        }
      } else {
        // Not authenticated, allow close
        await windowManager.destroy();
      }
    } catch (e) {
      // If any error occurs, allow close to prevent app from being stuck
      debugPrint('Error in close handler: $e');
      await windowManager.destroy();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Initialize core services
    final apiClient = ApiClient(baseUrl: AppConstants.baseUrl);
    final secureStorage = SecureStorage();
    final authManager = AuthManager(
      apiClient: apiClient,
      secureStorage: secureStorage,
    );

    return MultiProvider(
      providers: [
        // Core providers
        Provider<ApiClient>.value(value: apiClient),
        Provider<SecureStorage>.value(value: secureStorage),
        
        // Auth provider
        ChangeNotifierProvider<AuthManager>.value(value: authManager),
        
        // Feature providers
        ChangeNotifierProvider(create: (_) => ActivityProvider()),
        ChangeNotifierProvider(create: (context) => TeamProvider(
          apiClient: context.read<ApiClient>(),
        )),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (context) => SuperAdminProvider(
          apiClient: context.read<ApiClient>(),
        )),
        ChangeNotifierProvider(create: (context) => OrganizationProvider(
          apiClient: context.read<ApiClient>(),
        )),
        ChangeNotifierProvider(create: (context) => UserManagementProvider(
          apiClient: context.read<ApiClient>(),
        )),
        ChangeNotifierProvider(create: (context) => TimeTrackingProvider(
          apiClient: context.read<ApiClient>(),
        )),
        
        // Service providers
        Provider(create: (_) => MonitoringService()),
        Provider(create: (_) => PermissionService()),
      ],
      child: Consumer<AuthManager>(
        builder: (context, authManager, child) {
          return MaterialApp(
            title: AppConstants.appName,
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Color(AppConstants.lightTheme['primaryColor']),
                brightness: Brightness.light,
              ),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Color(AppConstants.darkTheme['primaryColor']),
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
            ),
            home: authManager.isLoading
                ? const SplashScreen()
                : authManager.isAuthenticated
                    ? const RoleBasedDashboard()
                    : const LoginScreen(),
            routes: {
              '/settings': (context) => const SettingsScreen(),
              '/login': (context) => const LoginScreen(),
              '/dashboard': (context) => const RoleBasedDashboard(),
            },
          );
        },
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.business,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              AppConstants.appName,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}