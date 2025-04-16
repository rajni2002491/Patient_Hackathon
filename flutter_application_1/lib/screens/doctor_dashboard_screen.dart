import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  bool _isRecording = false;
  String _transcription = '';
  List<Map<String, dynamic>> _patients = [];
  Map<String, dynamic>? _selectedPatient;

  @override
  void initState() {
    super.initState();
    _loadPatients();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    await _speech.initialize();
    await _flutterTts.setLanguage('en-US');
  }

  Future<void> _loadPatients() async {
    final doctorId = _auth.currentUser?.uid;
    if (doctorId == null) return;

    final snapshot = await _firestore
        .collection('patients')
        .where('doctorId', isEqualTo: doctorId)
        .get();

    setState(() {
      _patients = snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  Future<void> _startRecording() async {
    if (await _speech.initialize()) {
      setState(() => _isRecording = true);
      _speech.listen(
        onResult: (result) {
          setState(() {
            _transcription = result.recognizedWords;
          });
        },
      );
    }
  }

  Future<void> _stopRecording() async {
    await _speech.stop();
    setState(() => _isRecording = false);
    _saveVisitReport();
  }

  Future<void> _saveVisitReport() async {
    if (_selectedPatient == null || _transcription.isEmpty) return;

    await _firestore.collection('visit_reports').add({
      'patientId': _selectedPatient!['id'],
      'doctorId': _auth.currentUser?.uid,
      'transcription': _transcription,
      'status': 'draft',
      'timestamp': FieldValue.serverTimestamp(),
    });

    setState(() => _transcription = '');
  }

  Future<void> _sendReportToPatient(String reportId) async {
    await _firestore.collection('visit_reports').doc(reportId).update({
      'status': 'sent',
      'sentAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Dashboard'),
        actions: [
          IconButton(
            icon: Icon(_isRecording ? Icons.stop : Icons.mic),
            onPressed: _isRecording ? _stopRecording : _startRecording,
          ),
        ],
      ),
      body: Row(
        children: [
          // Patient List
          Container(
            width: 300,
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: ListView.builder(
              itemCount: _patients.length,
              itemBuilder: (context, index) {
                final patient = _patients[index];
                return ListTile(
                  title: Text(patient['name'] ?? 'Unknown'),
                  subtitle: Text(patient['email'] ?? ''),
                  selected: _selectedPatient?['id'] == patient['id'],
                  onTap: () {
                    setState(() => _selectedPatient = patient);
                  },
                );
              },
            ),
          ),
          // Patient Details and Reports
          Expanded(
            child: _selectedPatient == null
                ? const Center(child: Text('Select a patient'))
                : Column(
                    children: [
                      // Patient Profile
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedPatient!['name'],
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 8),
                            Text('Age: ${_selectedPatient!['age']}'),
                            Text('Gender: ${_selectedPatient!['gender']}'),
                          ],
                        ),
                      ),
                      // Visit Reports
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: _firestore
                              .collection('visit_reports')
                              .where('patientId',
                                  isEqualTo: _selectedPatient!['id'])
                              .orderBy('timestamp', descending: true)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            final reports = snapshot.data!.docs;
                            return ListView.builder(
                              itemCount: reports.length,
                              itemBuilder: (context, index) {
                                final report = reports[index].data()
                                    as Map<String, dynamic>;
                                return Card(
                                  margin: const EdgeInsets.all(8),
                                  child: ListTile(
                                    title: Text(
                                        'Visit Report - ${report['timestamp']?.toDate().toString() ?? 'Unknown date'}'),
                                    subtitle:
                                        Text(report['transcription'] ?? ''),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (report['status'] == 'draft')
                                          IconButton(
                                            icon: const Icon(Icons.edit),
                                            onPressed: () {
                                              // TODO: Implement report editing
                                            },
                                          ),
                                        IconButton(
                                          icon: const Icon(Icons.send),
                                          onPressed: () {
                                            _sendReportToPatient(
                                                reports[index].id);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
