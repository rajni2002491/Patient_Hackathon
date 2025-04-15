import 'package:flutter/material.dart';

class PatientProfileScreen extends StatelessWidget {
  const PatientProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: CircleAvatar(
                radius: 50,
                child: Icon(Icons.person, size: 50),
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'John Doe',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 24),
            _buildInfoCard(
              title: 'Personal Information',
              children: [
                _buildInfoRow('Age', '35'),
                _buildInfoRow('Gender', 'Male'),
                _buildInfoRow('Blood Type', 'O+'),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              title: 'Medical History',
              children: [
                _buildInfoRow('Allergies', 'None'),
                _buildInfoRow('Chronic Conditions', 'None'),
                _buildInfoRow('Medications', 'None'),
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
