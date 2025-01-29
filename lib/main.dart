import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:blind_assist/camara.dart';
import 'package:blind_assist/clockpage.dart';
import 'package:blind_assist/news.dart';
import 'package:blind_assist/help.dart';
import 'package:vibration/vibration.dart';
import 'package:blind_assist/splash_screen.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blind Assist',
      debugShowCheckedModeBanner: false, // Hide debug banner
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(), // Set SplashScreen as the entry point
    );
  }
}

class MainPage extends StatelessWidget {
  final FlutterTts flutterTts = FlutterTts();

  MainPage({super.key});

  Future<void> _onSingleTap(String buttonName) async {
    await flutterTts.speak('You tapped $buttonName');
  }

  void _onDoubleTap(BuildContext context, String buttonName) async {
    await flutterTts.speak('Navigating to $buttonName');
    if (!context.mounted) {
      return; // Check if the widget is still in the tree
    }
    switch (buttonName) {
      case 'Camera':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CameraPage()),
        );
        break;
      case 'Time':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ClockPage()),
        );
        break;
      case 'Malayalam News':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MalayalamNews()),
        );
        break;
      case 'Emergency Help':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HelpPage()),
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No page found for $buttonName')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Blind Assist'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        color: Color(0xFF2C2C34), // Premium non-gradient dark background
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                'Welcome to Blind Assist',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildFeatureCard(context, 'Camera', Icons.camera_alt, Colors.blue),
                  _buildFeatureCard(context, 'Time', Icons.watch_later_sharp, Colors.green),
                  _buildFeatureCard(context, 'Malayalam News', Icons.newspaper, Colors.pink),
                  _buildFeatureCard(context, 'Emergency Help', Icons.local_hospital, Colors.orange),
                ],
              ),
              Text(
                'Tap to explore features',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, String title, IconData icon, Color color) {
    return GestureDetector(
      onTap: () async {
        await _onSingleTap(title);
        Vibration.vibrate(duration: 100);
      },
      onDoubleTap: () async {
        _onDoubleTap(context, title);
        Vibration.vibrate(duration: 100);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 4),
              blurRadius: 6,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: color.withAlpha(01),
              child: Icon(
                icon,
                size: 32,
                color: color,
              ),
            ),
            SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
