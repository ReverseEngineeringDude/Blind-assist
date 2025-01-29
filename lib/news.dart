import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:vibration/vibration.dart';

class MalayalamNews extends StatefulWidget {
  const MalayalamNews({super.key});

  @override
  MalayalamNewsState createState() => MalayalamNewsState();
}

class MalayalamNewsState extends State<MalayalamNews> {
  final FlutterTts _flutterTts = FlutterTts();
  List<dynamic> _news = [];

  @override
  void initState() {
    super.initState();
    _initializeTTS();
    fetchNews();
  }

  // Initialize the TTS engine with Malayalam language
  Future<void> _initializeTTS() async {
    await _flutterTts.setLanguage('ml-IN');
    await _flutterTts.setPitch(1);
    await _flutterTts.setSpeechRate(0.5);
  }

  // Fetch news from the API
  Future<void> fetchNews() async {
    final response = await http.get(Uri.parse('https://levanter.onrender.com/news'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (mounted) {
        setState(() {
          _news = data['result'];
        });
      }
    } else {
      throw Exception('Failed to load news');
    }
  }

  // Speak the selected news title in Malayalam
  Future<void> _speakNews(String text) async {
    Vibration.vibrate(duration: 100);
    await _flutterTts.speak(text);
  }

  // Handle double-tap to navigate to the full article and speak it
  void _openFullNews(String url) async {
    Vibration.vibrate(duration: 100);
    final response = await http.get(Uri.parse('https://levanter.onrender.com/news?url=$url'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final String fullNews = data['result']; // Full news content

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FullNewsPage(newsContent: fullNews),
          ),
        );
      }
    } else {
      throw Exception('Failed to load full news');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Malayalam News'),
        backgroundColor: Colors.deepPurple,
      ),
      body: _news.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _news.length,
        itemBuilder: (context, index) {
          var newsItem = _news[index];
          return GestureDetector(
            onTap: () => _speakNews(newsItem['title']), // Speak the title on tap
            onDoubleTap: () => _openFullNews(newsItem['url']), // Open full news on double tap
            child: Card(
              margin: const EdgeInsets.all(8.0),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  newsItem['title'], // Display headline in card
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Full News Page to display the entire content
class FullNewsPage extends StatelessWidget {
  final String newsContent;
  final FlutterTts _flutterTts = FlutterTts();

  FullNewsPage({super.key, required this.newsContent}) {
    _initializeTTS();
  }

  // Initialize the TTS engine
  Future<void> _initializeTTS() async {
    await _flutterTts.setLanguage('ml-IN');
    await _flutterTts.setPitch(1);
    await _flutterTts.setSpeechRate(0.5);
  }

  // Speak the full news content
  Future<void> _speakFullNews() async {
    await _flutterTts.speak(newsContent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Full News'),
        backgroundColor: Colors.deepPurple,
      ),
      body: GestureDetector(
        onTap: () => _speakFullNews(), // Speak the full news content when tapped
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Text(
              newsContent, // Display the full news content
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ),
        ),
      ),
    );
  }
}
