import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  String? _patientId;
  Map<String, dynamic>? _patientData;
  int _currentSection = 1;

  // Speech to Text
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _lastWords = '';

  // Text to Speech
  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = false;

  Map<String, dynamic> _visitData = {
    'reason': '',
    'duration': '',
    'progression': '',
    'firstTime': '',
    'mainSymptom': '',
    'associatedSymptoms': [],
    'impact': '',
    'chronicConditions': [],
    'medications': [],
    'allergies': [],
    'recentTests': [],
    'severity': 0,
    'erConsideration': false,
    'selfCare': '',
    'expectations': '',
    'sendToDoctor': false,
    'copyPreference': '',
    'gdprConsent': false,
  };

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _initTts();
    _loadPatientData();
    _addWelcomeMessage();
  }

  Future<void> _initSpeech() async {
    await _speech.initialize();
    setState(() {});
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  void _startListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) {
            setState(() {
              _lastWords = result.recognizedWords;
              _textController.text = _lastWords;
            });
          },
          listenMode: stt.ListenMode.confirmation,
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
      if (_lastWords.isNotEmpty) {
        _handleSubmitted(_lastWords);
      }
    }
  }

  Future<void> _speak(String text) async {
    if (!_isSpeaking) {
      setState(() => _isSpeaking = true);
      _flutterTts.setCompletionHandler(() {
        setState(() => _isSpeaking = false);
      });
      await _flutterTts.speak(text);
    }
  }

  @override
  void dispose() {
    _speech.stop();
    _flutterTts.stop();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _loadPatientData() async {
    final prefs = await SharedPreferences.getInstance();
    _patientId = prefs.getString('patientId');
    if (_patientId != null) {
      final doc = await FirebaseFirestore.instance
          .collection('patients')
          .doc(_patientId)
          .get();
      if (doc.exists) {
        setState(() {
          _patientData = doc.data();
        });
      }
    }
  }

  void _addWelcomeMessage() {
    _addBotMessage(
      'Hello! I\'m here to help you prepare for your upcoming visit. Let\'s go through some questions to create a comprehensive report for your doctor.',
    );
    _addBotMessage(
      'First, let\'s confirm your information. Is this correct?\n\n'
      'Name: ${_patientData?['name'] ?? 'Not provided'}\n'
      'Age: ${_patientData?['age'] ?? 'Not provided'}\n'
      'Gender: ${_patientData?['gender'] ?? 'Not provided'}\n'
      'Doctor: ${_patientData?['doctor'] ?? 'Not provided'}',
      buttons: [
        ElevatedButton(
          onPressed: () {
            _addUserMessage('Yes, that\'s correct');
            _startSection2();
          },
          child: const Text('Yes, that\'s correct'),
        ),
        ElevatedButton(
          onPressed: () {
            _addUserMessage('No, I need to update my information');
            _addBotMessage(
              'Please contact the clinic to update your information before proceeding.',
            );
          },
          child: const Text('No, I need to update'),
        ),
      ],
    );
  }

  void _startSection2() {
    _currentSection = 2;
    _addBotMessage(
      'Why did you book this visit?',
      buttons: [
        ElevatedButton(
          onPressed: () => _handleReasonSelection('pain/symptoms'),
          child: const Text('Pain/Symptoms'),
        ),
        ElevatedButton(
          onPressed: () => _handleReasonSelection('check-up'),
          child: const Text('Check-up'),
        ),
        ElevatedButton(
          onPressed: () => _handleReasonSelection('test results'),
          child: const Text('Test Results'),
        ),
        ElevatedButton(
          onPressed: () => _handleReasonSelection('prescription'),
          child: const Text('Prescription'),
        ),
        ElevatedButton(
          onPressed: () => _handleReasonSelection('other'),
          child: const Text('Other'),
        ),
      ],
    );
  }

  void _handleReasonSelection(String reason) {
    _visitData['reason'] = reason;
    _addUserMessage('I booked the visit because: $reason');
    _addBotMessage(
      'Please describe your reason in your own words:',
    );
  }

  void _handleDurationSelection(String duration) {
    _visitData['duration'] = duration;
    _addUserMessage('Duration: $duration');
    _addBotMessage(
      'How has this issue progressed?',
      buttons: [
        ElevatedButton(
          onPressed: () => _handleProgressionSelection('worsened'),
          child: const Text('Worsened'),
        ),
        ElevatedButton(
          onPressed: () => _handleProgressionSelection('stable'),
          child: const Text('Stable'),
        ),
        ElevatedButton(
          onPressed: () => _handleProgressionSelection('improved'),
          child: const Text('Improved'),
        ),
      ],
    );
  }

  void _handleProgressionSelection(String progression) {
    _visitData['progression'] = progression;
    _addUserMessage('Progression: $progression');
    _addBotMessage(
      'Is this the first time you\'re experiencing this?',
      buttons: [
        ElevatedButton(
          onPressed: () => _handleFirstTimeSelection('yes'),
          child: const Text('Yes'),
        ),
        ElevatedButton(
          onPressed: () => _handleFirstTimeSelection('no'),
          child: const Text('No'),
        ),
        ElevatedButton(
          onPressed: () => _handleFirstTimeSelection('recurring'),
          child: const Text('Recurring Episode'),
        ),
      ],
    );
  }

  void _handleFirstTimeSelection(String firstTime) {
    _visitData['firstTime'] = firstTime;
    _addUserMessage('First time: $firstTime');
    _startSection3();
  }

  void _startSection3() {
    _currentSection = 3;
    _addBotMessage(
      'What is your main symptom?',
    );
  }

  void _handleMainSymptom(String symptom) {
    _visitData['mainSymptom'] = symptom;
    _addUserMessage('Main symptom: $symptom');
    _addBotMessage(
      'Do you have any related symptoms?',
      buttons: _getAssociatedSymptomsButtons(symptom),
    );
  }

  List<Widget> _getAssociatedSymptomsButtons(String mainSymptom) {
    // This would be expanded with a proper symptom association database
    final Map<String, List<String>> symptomAssociations = {
      'chest pain': [
        'shortness of breath',
        'nausea',
        'palpitations',
        'sweating',
        'radiating pain'
      ],
      'headache': ['nausea', 'light sensitivity', 'dizziness', 'fatigue'],
      'fever': ['chills', 'sweating', 'fatigue', 'body aches'],
    };

    final associatedSymptoms =
        symptomAssociations[mainSymptom.toLowerCase()] ?? [];
    return [
      ...associatedSymptoms.map((symptom) => ElevatedButton(
            onPressed: () => _handleAssociatedSymptom(symptom, true),
            child: Text(symptom),
          )),
      ElevatedButton(
        onPressed: () => _addBotMessage(
          'Please describe any other symptoms:',
        ),
        child: const Text('Other Symptoms'),
      ),
      ElevatedButton(
        onPressed: () => _handleImpactSelection(),
        child: const Text('No other symptoms'),
      ),
    ];
  }

  void _handleAssociatedSymptom(String symptom, bool present) {
    _visitData['associatedSymptoms'].add({
      'name': symptom,
      'present': present,
    });
    _addUserMessage(
        'Associated symptom: $symptom (${present ? 'present' : 'absent'})');
  }

  void _handleImpactSelection() {
    _addBotMessage(
      'How do these symptoms impact your daily life?',
      buttons: [
        ElevatedButton(
          onPressed: () => _handleImpact('none'),
          child: const Text('No Impact'),
        ),
        ElevatedButton(
          onPressed: () => _handleImpact('partial'),
          child: const Text('Partial Impact'),
        ),
        ElevatedButton(
          onPressed: () => _handleImpact('severe'),
          child: const Text('Severe Impact'),
        ),
      ],
    );
  }

  void _handleImpact(String impact) {
    _visitData['impact'] = impact;
    _addUserMessage('Impact: $impact');
    _startSection4();
  }

  void _startSection4() {
    _currentSection = 4;
    _addBotMessage(
      'Let\'s review your medical background:',
    );
    _addBotMessage(
      'Known chronic conditions:',
      buttons: [
        ElevatedButton(
          onPressed: () => _handleChronicCondition('hypertension'),
          child: const Text('Hypertension'),
        ),
        ElevatedButton(
          onPressed: () => _handleChronicCondition('diabetes'),
          child: const Text('Diabetes'),
        ),
        ElevatedButton(
          onPressed: () => _handleChronicCondition('asthma'),
          child: const Text('Asthma'),
        ),
        ElevatedButton(
          onPressed: () => _addBotMessage('Please specify other conditions:'),
          child: const Text('Other'),
        ),
      ],
    );
  }

  void _handleChronicCondition(String condition) {
    _visitData['chronicConditions'].add(condition);
    _addUserMessage('Chronic condition: $condition');
    _addBotMessage(
      'Current medications:',
      buttons: [
        ElevatedButton(
          onPressed: () => _handleMedication('metformin'),
          child: const Text('Metformin'),
        ),
        ElevatedButton(
          onPressed: () => _handleMedication('lisinopril'),
          child: const Text('Lisinopril'),
        ),
        ElevatedButton(
          onPressed: () => _addBotMessage('Please specify other medications:'),
          child: const Text('Other'),
        ),
      ],
    );
  }

  void _handleMedication(String medication) {
    _visitData['medications'].add(medication);
    _addUserMessage('Medication: $medication');
    _addBotMessage(
      'Any allergies?',
      buttons: [
        ElevatedButton(
          onPressed: () => _handleAllergy('penicillin'),
          child: const Text('Penicillin'),
        ),
        ElevatedButton(
          onPressed: () => _handleAllergy('aspirin'),
          child: const Text('Aspirin'),
        ),
        ElevatedButton(
          onPressed: () => _addBotMessage('Please specify other allergies:'),
          child: const Text('Other'),
        ),
        ElevatedButton(
          onPressed: () => _handleAllergy('none'),
          child: const Text('No Allergies'),
        ),
      ],
    );
  }

  void _handleAllergy(String allergy) {
    if (allergy != 'none') {
      _visitData['allergies'].add(allergy);
    }
    _addUserMessage('Allergy: $allergy');
    _startSection5();
  }

  void _startSection5() {
    _currentSection = 5;
    _addBotMessage(
      'On a scale of 1-5, how severe do you perceive this problem to be?',
      buttons: List.generate(
        5,
        (index) => ElevatedButton(
          onPressed: () => _handleSeverity(index + 1),
          child: Text('${index + 1}'),
        ),
      ),
    );
  }

  void _handleSeverity(int severity) {
    _visitData['severity'] = severity;
    _addUserMessage('Severity: $severity');
    _addBotMessage(
      'Have you considered going to the emergency room?',
      buttons: [
        ElevatedButton(
          onPressed: () => _handleERConsideration(true),
          child: const Text('Yes'),
        ),
        ElevatedButton(
          onPressed: () => _handleERConsideration(false),
          child: const Text('No'),
        ),
      ],
    );
  }

  void _handleERConsideration(bool considered) {
    _visitData['erConsideration'] = considered;
    _addUserMessage('ER consideration: ${considered ? 'yes' : 'no'}');
    _addBotMessage(
      'What have you done to feel better?',
    );
  }

  void _handleSelfCare(String selfCare) {
    _visitData['selfCare'] = selfCare;
    _addUserMessage('Self-care: $selfCare');
    _addBotMessage(
      'What do you expect from this visit?',
      buttons: [
        ElevatedButton(
          onPressed: () => _handleExpectation('diagnosis'),
          child: const Text('Diagnosis'),
        ),
        ElevatedButton(
          onPressed: () => _handleExpectation('prescription'),
          child: const Text('Prescription'),
        ),
        ElevatedButton(
          onPressed: () => _handleExpectation('reassurance'),
          child: const Text('Reassurance'),
        ),
        ElevatedButton(
          onPressed: () => _handleExpectation('follow-up'),
          child: const Text('Follow-up'),
        ),
      ],
    );
  }

  void _handleExpectation(String expectation) {
    _visitData['expectations'] = expectation;
    _addUserMessage('Expectation: $expectation');
    _startSection6();
  }

  void _startSection6() {
    _currentSection = 6;
    _addBotMessage(
      'Would you like to send this report to your doctor before the visit?',
      buttons: [
        ElevatedButton(
          onPressed: () => _handleSendToDoctor(true),
          child: const Text('Yes'),
        ),
        ElevatedButton(
          onPressed: () => _handleSendToDoctor(false),
          child: const Text('No'),
        ),
      ],
    );
  }

  void _handleSendToDoctor(bool send) {
    _visitData['sendToDoctor'] = send;
    _addUserMessage('Send to doctor: ${send ? 'yes' : 'no'}');
    _addBotMessage(
      'Would you like a copy of the report?',
      buttons: [
        ElevatedButton(
          onPressed: () => _handleCopyPreference('email'),
          child: const Text('Email'),
        ),
        ElevatedButton(
          onPressed: () => _handleCopyPreference('whatsapp'),
          child: const Text('WhatsApp'),
        ),
        ElevatedButton(
          onPressed: () => _handleCopyPreference('none'),
          child: const Text('No Copy'),
        ),
      ],
    );
  }

  void _handleCopyPreference(String preference) {
    _visitData['copyPreference'] = preference;
    _addUserMessage('Copy preference: $preference');
    _addBotMessage(
      'Please confirm your consent to process this data according to GDPR regulations:',
      buttons: [
        ElevatedButton(
          onPressed: () => _handleGDPRConsent(true),
          child: const Text('I Consent'),
        ),
        ElevatedButton(
          onPressed: () => _handleGDPRConsent(false),
          child: const Text('I Do Not Consent'),
        ),
      ],
    );
  }

  void _handleGDPRConsent(bool consent) {
    _visitData['gdprConsent'] = consent;
    _addUserMessage('GDPR consent: ${consent ? 'yes' : 'no'}');
    if (consent) {
      _generateReport();
    } else {
      _addBotMessage(
        'I\'m sorry, but we cannot proceed without your consent. Please contact the clinic directly.',
      );
    }
  }

  void _generateReport() {
    _addBotMessage(
      'Thank you for completing the pre-visit questionnaire. Here\'s your report:',
    );
    _addBotMessage(
      '1. Reason for Visit\n'
      '${_visitData['reason']}\n'
      'Duration: ${_visitData['duration']}\n'
      'Progression: ${_visitData['progression']}\n'
      'First time: ${_visitData['firstTime']}\n\n'
      '2. Symptoms and Impact\n'
      'Main symptom: ${_visitData['mainSymptom']}\n'
      'Associated symptoms: ${_visitData['associatedSymptoms'].join(', ')}\n'
      'Impact: ${_visitData['impact']}\n\n'
      '3. Clinical Background\n'
      'Chronic conditions: ${_visitData['chronicConditions'].join(', ')}\n'
      'Medications: ${_visitData['medications'].join(', ')}\n'
      'Allergies: ${_visitData['allergies'].join(', ')}\n\n'
      '4. Patient Goals\n'
      'Perceived severity: ${_visitData['severity']}/5\n'
      'ER consideration: ${_visitData['erConsideration'] ? 'Yes' : 'No'}\n'
      'Self-care attempts: ${_visitData['selfCare']}\n'
      'Expectations: ${_visitData['expectations']}',
    );
  }

  void _handleSubmitted(String text) {
    _textController.clear();
    _addUserMessage(text);

    switch (_currentSection) {
      case 2:
        _visitData['reason'] = text;
        _addBotMessage(
          'How long have you been experiencing this?',
          buttons: [
            ElevatedButton(
              onPressed: () => _handleDurationSelection('hours'),
              child: const Text('Hours'),
            ),
            ElevatedButton(
              onPressed: () => _handleDurationSelection('days'),
              child: const Text('Days'),
            ),
            ElevatedButton(
              onPressed: () => _handleDurationSelection('weeks'),
              child: const Text('Weeks'),
            ),
            ElevatedButton(
              onPressed: () => _handleDurationSelection('months'),
              child: const Text('Months'),
            ),
          ],
        );
        break;
      case 3:
        _handleMainSymptom(text);
        break;
      case 4:
        _handleChronicCondition(text);
        break;
      case 5:
        _handleSelfCare(text);
        break;
    }
  }

  void _addUserMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
      ));
    });
    _scrollToBottom();
  }

  void _addBotMessage(String text, {List<Widget>? buttons}) {
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: false,
        buttons: buttons,
      ));
    });
    _scrollToBottom();
    _speak(text);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pre-Visit Chatbot'),
        actions: [
          IconButton(
            icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
            onPressed: _startListening,
            tooltip: 'Voice Input',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Column(
                    crossAxisAlignment: message.isUser
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: message.isUser
                              ? Theme.of(context).primaryColor
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!message.isUser)
                              IconButton(
                                icon: Icon(
                                  _isSpeaking
                                      ? Icons.volume_up
                                      : Icons.volume_down,
                                  size: 20,
                                ),
                                onPressed: () => _speak(message.text),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            Flexible(
                              child: Text(
                                message.text,
                                style: TextStyle(
                                  color: message.isUser
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (message.buttons != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: message.buttons!,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
            ),
            child: _buildTextComposer(),
          ),
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Flexible(
            child: TextField(
              controller: _textController,
              onSubmitted: _handleSubmitted,
              decoration: InputDecoration(
                hintText:
                    _isListening ? 'Listening...' : 'Type your message...',
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
            onPressed: _startListening,
            tooltip: 'Voice Input',
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () => _handleSubmitted(_textController.text),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final List<Widget>? buttons;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.buttons,
  });
}
