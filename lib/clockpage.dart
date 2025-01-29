import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';
import 'package:vibration/vibration.dart';

class ClockPage extends StatefulWidget {
  const ClockPage({super.key});

  @override
  ClockPageState createState() => ClockPageState();
}

class ClockPageState extends State<ClockPage> {
  final FlutterTts _flutterTts = FlutterTts();
  String _currentTime = "";
  String _currentDate = "";

  @override
  void initState() {
    super.initState();
    _updateTime();
  }

  // Update the time and date every second
  void _updateTime() {
    setState(() {
      _currentTime = DateFormat('hh:mm a').format(DateTime.now());
      _currentDate = DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now());
    });
    // Update every second
    Future.delayed(Duration(seconds: 1), _updateTime);
  }

  // Speak the time
  Future<void> _speakTime() async {
    Vibration.vibrate(duration: 100);
    await _flutterTts.speak('Current time is $_currentTime');
  }

  // Speak the date
  Future<void> _speakDate() async {
    Vibration.vibrate(duration: 100);
    await _flutterTts.speak('Today\'s date is $_currentDate');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clock'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: GestureDetector(
          onTap: () async {
            await _speakTime();  // Speak the time when tapped
          },
          onDoubleTap: () async {
            await _speakDate();  // Speak the date when double-tapped
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _currentTime, // Show the current time
                style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text(
                _currentDate, // Show the current date
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
