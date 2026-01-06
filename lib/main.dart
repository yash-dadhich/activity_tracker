import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'presentation/screens/dashboard/role_based_dashboard.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'screens/settings_screen.dart';
import 'services/monitoring_service.dart';
import 'services/permission_service.dart';
import 'providers/activity_provider.dart';
import 'providers/team_provider.dart';
import 'providers/admin_provider.dart';
import 'core/auth/auth_manager.dart';
import 'core/network/api_client.dart';
import 'core/storage/secure_storage.dart';
import 'core/constants/app_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
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
  );
  
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
        
        // Service providers
        Provider(create: (_) => MonitoringService()),
        Provider(create: (_) => PermissionService()),
      ],
      child: Consumer<AuthManager>(
        builder: (context, authManager, child) {
          return MaterialApp(
            title: AppConstants.appName,
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