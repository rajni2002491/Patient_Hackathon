import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReportScreen extends ConsumerStatefulWidget {
  final String patientId;

  const ReportScreen({Key? key, required this.patientId}) : super(key: key);

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  Map<String, dynamic>? clinicalData;
  String? lifestyleFeedback;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchReportData();
  }

  Future<void> fetchReportData() async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('clinical_reports')
          .doc(widget.patientId)
          .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        setState(() {
          clinicalData = data['structured_data'];
          lifestyleFeedback = data['lifestyle_feedback'];
          isLoading = false;
        });
      } else {
        setState(() {
          clinicalData = null;
          lifestyleFeedback = 'No report found.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        lifestyleFeedback = 'Failed to fetch report.';
        isLoading = false;
      });
    }
  }

  Widget buildDataTile(String title, dynamic value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value.toString()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clinical Report'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : clinicalData == null
              ? const Center(child: Text('No report available'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '🩺 Structured Clinical Data',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ...clinicalData!.entries
                          .map((entry) => buildDataTile(entry.key, entry.value))
                          .toList(),
                      const SizedBox(height: 24),
                      const Text(
                        '🧠 AI-Powered Lifestyle Feedback',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        color: Colors.blue.shade50,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            lifestyleFeedback ?? 'No feedback available.',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
