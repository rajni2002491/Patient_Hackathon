import 'package:flutter/material.dart';

class DoctorProfileScreen extends StatelessWidget {
  const DoctorProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: CircleAvatar(
                radius: 50,
                child: Icon(Icons.medical_services, size: 50),
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Dr. Sarah Smith',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 24),
            _buildInfoCard(
              title: 'Professional Information',
              children: [
                _buildInfoRow('Specialization', 'Cardiology'),
                _buildInfoRow('Years of Experience', '15'),
                _buildInfoRow('Hospital', 'City General Hospital'),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              title: 'Contact Information',
              children: [
                _buildInfoRow('Email', 'dr.smith@hospital.com'),
                _buildInfoRow('Phone', '+1 (555) 123-4567'),
                _buildInfoRow('Office Hours', 'Mon-Fri, 9:00 AM - 5:00 PM'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }
}
