import 'package:flutter/material.dart';

class TherapyManagementScreen extends StatelessWidget {
  const TherapyManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Therapy Management'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTherapyCard(
              title: 'Physical Therapy',
              description: 'Daily exercises for knee rehabilitation',
              schedule: 'Every Monday, Wednesday, Friday at 10:00 AM',
              status: 'Active',
            ),
            const SizedBox(height: 16),
            _buildTherapyCard(
              title: 'Occupational Therapy',
              description: 'Hand and wrist exercises',
              schedule: 'Every Tuesday, Thursday at 2:00 PM',
              status: 'Active',
            ),
            const SizedBox(height: 16),
            _buildTherapyCard(
              title: 'Speech Therapy',
              description: 'Language and communication exercises',
              schedule: 'Every Saturday at 11:00 AM',
              status: 'Completed',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Add new therapy session
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTherapyCard({
    required String title,
    required String description,
    required String schedule,
    required String status,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: status == 'Active'
                        ? Colors.green.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: status == 'Active' ? Colors.green : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 8),
                Text(schedule),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // TODO: View therapy details
                  },
                  child: const Text('View Details'),
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Schedule appointment
                  },
                  child: const Text('Schedule'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
