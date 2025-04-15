import 'package:flutter/material.dart';
import 'dart:math';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  late AnimationController _typingAnimationController;
  late Animation<double> _typingAnimation;
  final Random _random = Random();
  final List<String> _greetings = [
    "Hello! I'm your AI healthcare assistant. How can I help you today?",
    "Hi there! I'm here to assist you with your health-related questions.",
    "Welcome! I'm your virtual healthcare companion. What can I help you with?",
  ];
  final List<String> _acknowledgments = [
    "I understand. Let me help you with that.",
    "I see. Here's what I can tell you about that.",
    "Thanks for sharing. Let me provide some information about that.",
  ];
  final Map<String, List<String>> _responses = {
    'symptoms': [
      "Based on your symptoms, I recommend consulting a healthcare professional for proper diagnosis.",
      "Those symptoms could indicate several conditions. It's best to get checked by a doctor.",
      "I understand you're experiencing symptoms. Let me suggest some general advice while you wait for your appointment.",
    ],
    'medication': [
      "Always follow your doctor's prescription and dosage instructions carefully.",
      "Make sure to take your medication as prescribed and don't skip doses.",
      "If you're experiencing any side effects, contact your healthcare provider immediately.",
    ],
    'appointment': [
      "Would you like help scheduling an appointment with a healthcare provider?",
      "I can help you find available appointment slots with doctors in your area.",
      "Let me check the available appointments for you.",
    ],
    'general': [
      "Maintaining a healthy lifestyle is important for overall well-being.",
      "Regular exercise and a balanced diet are key to good health.",
      "Don't forget to stay hydrated and get enough sleep.",
    ],
  };

  @override
  void initState() {
    super.initState();
    _typingAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _typingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _typingAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    // Add initial bot message with random greeting
    _addBotMessage(_greetings[_random.nextInt(_greetings.length)]);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _typingAnimationController.dispose();
    super.dispose();
  }

  void _addBotMessage(String text) {
    setState(() {
      _messages.insert(
          0,
          ChatMessage(
            text: text,
            isUser: false,
          ));
    });
  }

  String _generateResponse(String userMessage) {
    // Convert message to lowercase for easier matching
    final message = userMessage.toLowerCase();

    // Check for keywords and generate appropriate response
    if (message.contains('symptom') ||
        message.contains('pain') ||
        message.contains('ache')) {
      return _responses['symptoms']![
          _random.nextInt(_responses['symptoms']!.length)];
    } else if (message.contains('medic') ||
        message.contains('pill') ||
        message.contains('drug')) {
      return _responses['medication']![
          _random.nextInt(_responses['medication']!.length)];
    } else if (message.contains('appointment') ||
        message.contains('schedule') ||
        message.contains('book')) {
      return _responses['appointment']![
          _random.nextInt(_responses['appointment']!.length)];
    } else {
      return _responses['general']![
          _random.nextInt(_responses['general']!.length)];
    }
  }

  Future<void> _handleSubmitted(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.insert(
          0,
          ChatMessage(
            text: text,
            isUser: true,
          ));
      _isLoading = true;
    });

    _messageController.clear();

    // Simulate AI processing time (random delay between 1-3 seconds)
    final delay = Duration(seconds: 1 + _random.nextInt(3));
    await Future.delayed(delay);

    if (mounted) {
      setState(() {
        _isLoading = false;
        // Add acknowledgment message
        _addBotMessage(
            _acknowledgments[_random.nextInt(_acknowledgments.length)]);

        // Add main response after a short delay
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _addBotMessage(_generateResponse(text));
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: theme.primaryColor.withOpacity(0.2),
              child: const Icon(Icons.health_and_safety, color: Colors.white),
            ),
            const SizedBox(width: 12),
            const Text('AI Health Assistant'),
          ],
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
              ),
              child: ListView.builder(
                reverse: true,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _messages.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == 0 && _isLoading) {
                    return _buildTypingIndicator();
                  }
                  return _messages[index - (_isLoading ? 1 : 0)];
                },
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: _buildTextComposer(),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            margin: const EdgeInsets.only(right: 16.0),
            child: const CircleAvatar(
              backgroundColor: Colors.blue,
              child: Icon(Icons.health_and_safety, color: Colors.white),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypingDot(0),
                const SizedBox(width: 4),
                _buildTypingDot(0.2),
                const SizedBox(width: 4),
                _buildTypingDot(0.4),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(double delay) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _typingAnimationController,
          curve: Interval(delay, delay + 0.3, curve: Curves.easeInOut),
        ),
      ),
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: Colors.grey,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildTextComposer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onSubmitted: _handleSubmitted,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: () => _handleSubmitted(_messageController.text),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isUser;

  const ChatMessage({
    super.key,
    required this.text,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser)
            Container(
              margin: const EdgeInsets.only(right: 16.0),
              child: const CircleAvatar(
                backgroundColor: Colors.blue,
                child: Icon(Icons.health_and_safety, color: Colors.white),
              ),
            ),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              decoration: BoxDecoration(
                color: isUser ? theme.primaryColor : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: isUser
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),
          if (isUser)
            Container(
              margin: const EdgeInsets.only(left: 16.0),
              child: const CircleAvatar(
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
