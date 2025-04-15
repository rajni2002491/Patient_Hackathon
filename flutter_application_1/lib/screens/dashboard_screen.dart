import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'patient_profile_screen.dart';
import 'doctor_profile_screen.dart';
import 'messaging_screen.dart';
import 'therapy_management_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HealthCare Connect'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _signOut(context),
          ),
        ],
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _DashboardCard(
            title: 'Patient Profile',
            icon: Icons.person,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const PatientProfileScreen()),
            ),
          ),
          _DashboardCard(
            title: 'Doctor Profile',
            icon: Icons.medical_services,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const DoctorProfileScreen()),
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
            icon: Icons.medication,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const TherapyManagementScreen()),
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
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
