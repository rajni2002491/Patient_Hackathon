import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/patient_profile_screen.dart';
import 'screens/doctor_profile_screen.dart';
import 'screens/messaging_screen.dart';
import 'screens/therapy_management_screen.dart';
import 'screens/reports_screen.dart';
import 'theme/app_theme.dart';
import 'providers/theme_provider.dart';

void main() {
  runApp(
    const ProviderScope(
      child: HealthCareApp(),
    ),
  );
}

class HealthCareApp extends ConsumerWidget {
  const HealthCareApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);
    const String patientId = 'test-patient-id';

    return MaterialApp(
      title: 'HealthCare Connect',
      theme: isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
      home: const AuthWrapper(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/patient-profile': (context) =>
            PatientProfileScreen(patientId: patientId),
        '/doctor-profile': (context) => const DoctorProfileScreen(),
        '/messaging': (context) => const MessagingScreen(),
        '/therapy': (context) => const TherapyManagementScreen(),
        '/reports': (context) => ReportsScreen(patientId: patientId),
      },
    );
  }
}

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);
    return _AuthWrapperContent(isDarkMode: isDarkMode);
  }
}

class _AuthWrapperContent extends StatefulWidget {
  final bool isDarkMode;

  const _AuthWrapperContent({required this.isDarkMode});

  @override
  State<_AuthWrapperContent> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<_AuthWrapperContent> {
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return _isLoggedIn ? const DashboardScreen() : const LoginScreen();
  }
}
