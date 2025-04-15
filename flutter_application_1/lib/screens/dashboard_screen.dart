import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'chatbot_screen.dart';
import 'patient_profile_screen.dart';
import 'reports_screen.dart';
import 'messaging_screen.dart';
import 'therapy_management_screen.dart';
import '../providers/theme_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);
    const String patientId = 'test-patient-id';

    return Scaffold(
      appBar: AppBar(
        title: const Text('HealthCare Connect'),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
            tooltip:
                isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        children: [
          _DashboardCard(
            title: 'AI Chatbot',
            icon: Icons.chat,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ChatbotScreen()),
            ),
          ),
          _DashboardCard(
            title: 'Health Profile',
            icon: Icons.person,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    PatientProfileScreen(patientId: patientId),
              ),
            ),
          ),
          _DashboardCard(
            title: 'Reports',
            icon: Icons.description,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReportsScreen(patientId: patientId),
              ),
            ),
          ),
          _DashboardCard(
            title: 'Messaging',
            icon: Icons.message,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MessagingScreen()),
            ),
          ),
          _DashboardCard(
            title: 'Therapy Management',
            icon: Icons.medical_services,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TherapyManagementScreen(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
