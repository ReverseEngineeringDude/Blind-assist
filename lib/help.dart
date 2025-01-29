import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vibration/vibration.dart';
import 'dart:async';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  HelpPageState createState() => HelpPageState();
}

class HelpPageState extends State<HelpPage> with SingleTickerProviderStateMixin {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isHelpActive = true;
  Timer? _vibrationTimer;

  final Map<String, String> _userData = {
    'name': 'John Doe',
    'phone': '+91 9876543210',
    'bloodGroup': 'O+',
    'location': 'Kozhikode, Kerala, India'
  };

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeTTS();
    _startEmergencyActions();

    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true); // Loop animation with reverse
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _vibrationTimer?.cancel();
    _flutterTts.stop();
    super.dispose();
  }

  // Initialize TTS
  Future<void> _initializeTTS() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setPitch(1);
    await _flutterTts.setSpeechRate(0.5);
  }

  // Start the emergency actions
  void _startEmergencyActions() {
    _announceHelp();
    _startVibration();
    _sendUserDataToVolunteers();
  }

  // Announce the help actions
  Future<void> _announceHelp() async {
    await _flutterTts.speak(
        'Emergency help is being requested. Your data has been sent to nearby volunteers. The phone will vibrate every 5 seconds. Long press anywhere on the screen to stop.');
  }

  // Start phone vibration every 5 seconds
  void _startVibration() {
    _vibrationTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_isHelpActive && Vibration.hasVibrator() != null) {
        Vibration.vibrate(duration: 1000); // Vibrate for 1 second
      }
    });
  }

  // Simulate sending user data to volunteers
  void _sendUserDataToVolunteers() {
    // Simulate sending user data
    print('User data sent to volunteers: $_userData');
  }

  // Stop all help actions
  void _stopEmergencyActions() {
    if (mounted) {
      setState(() {
        _isHelpActive = false;
      });
    }
    _vibrationTimer?.cancel();
    _flutterTts.speak('Emergency actions have been stopped.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Help'),
        backgroundColor: Colors.red,
      ),
      body: GestureDetector(
        onLongPress: _stopEmergencyActions, // Detect long press anywhere inside the body
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Pulsing Icon with Scale Animation
              ScaleTransition(
                scale: _scaleAnimation,
                child: const Icon(
                  Icons.warning,
                  size: 100,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 20),
              // Animated Emergency Text
              AnimatedOpacity(
                opacity: _isHelpActive ? 1.0 : 0.0,
                duration: const Duration(seconds: 1),
                child: const Text(
                  'Emergency Help Activated',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              // Sliding Text for Additional Instructions
              AnimatedSlide(
                offset: _isHelpActive ? Offset.zero : const Offset(0, 1),
                duration: const Duration(seconds: 1),
                child: Text(
                  'Sending data to nearby volunteers...',
                  style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Long press anywhere to stop.',
                style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
