import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/patient_profile_screen.dart';
import 'screens/doctor_profile_screen.dart';
import 'screens/messaging_screen.dart';
import 'screens/therapy_management_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const HealthCareApp());
}

class HealthCareApp extends StatelessWidget {
  const HealthCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HealthCare Connect',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const AuthWrapper(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/patient-profile': (context) => const PatientProfileScreen(),
        '/doctor-profile': (context) => const DoctorProfileScreen(),
        '/messaging': (context) => const MessagingScreen(),
        '/therapy': (context) => const TherapyManagementScreen(),
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
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
