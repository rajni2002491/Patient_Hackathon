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
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'screens/chatbot_screen.dart';
import 'screens/doctor_dashboard_screen.dart';
import 'screens/report_edit_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode =
        ref.watch(themeProvider) ? ThemeMode.dark : ThemeMode.light;

    return MaterialApp(
      title: 'MedicinAmica',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const AuthWrapper(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/chatbot': (context) => const ChatbotScreen(),
        '/doctor-dashboard': (context) => const DoctorDashboardScreen(),
        '/therapy': (context) => const TherapyManagementScreen(),
        '/reports': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map;
          return ReportsScreen(patientId: args['patientId']);
        },
        '/edit-report': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map;
          return ReportEditScreen(
            reportId: args['reportId'],
            initialContent: args['content'],
          );
        },
      },
    );
  }
}

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData) {
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(snapshot.data!.uid)
                .get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final userData =
                  userSnapshot.data?.data() as Map<String, dynamic>?;
              final isDoctor = userData?['role'] == 'doctor';

              return isDoctor
                  ? const DoctorDashboardScreen()
                  : const ChatbotScreen();
            },
          );
        }

        return const LoginScreen();
      },
    );
  }
}
