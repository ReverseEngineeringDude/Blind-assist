import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'dart:convert';
import 'package:flutter_tts/flutter_tts.dart'; // Import flutter_tts
import 'package:vibration/vibration.dart';

class ObjectPage extends StatefulWidget {
  final String imagePath;

  const ObjectPage({super.key, required this.imagePath});

  @override
  ObjectPageState createState() => ObjectPageState();
}

class ObjectPageState extends State<ObjectPage> {
  String? _detectedObject;
  bool _isLoading = false;
  final FlutterTts _flutterTts = FlutterTts(); // Initialize FlutterTts

  @override
  void initState() {
    super.initState();
    _identifyObject();
  }

  Future<void> _identifyObject() async {
    setState(() => _isLoading = true);

    try {
      // Prepare the image file
      File imageFile = File(widget.imagePath);
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Imagga API request
      final response = await http.post(
        Uri.parse('https://api.imagga.com/v2/tags'),
        headers: {
          'Authorization': 'Basic ${base64Encode(
              utf8.encode('acc_9c0e24757402753:580c0959f212e5fc67dc3b6d5f68bfcf'))}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'image_base64': base64Image,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final tags = data['result']['tags'];
        setState(() => _detectedObject = tags != null && tags.isNotEmpty
            ? tags[0]['tag']['en']
            : 'No object detected');
      } else {
        debugPrint('Imagga API Error: ${response.body}');
        await _useMLKit();
      }
    } catch (e) {
      debugPrint('Imagga API Exception: $e');
      await _useMLKit();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _useMLKit() async {
    try {
      final inputImage = InputImage.fromFilePath(widget.imagePath);
      final imageLabeler = ImageLabeler(options: ImageLabelerOptions(confidenceThreshold: 0.5));
      final List<ImageLabel> labels = await imageLabeler.processImage(inputImage);

      if (labels.isNotEmpty) {
        setState(() => _detectedObject = labels.first.label);
      } else {
        setState(() => _detectedObject = 'No object detected');
      }

      imageLabeler.close();
    } catch (e) {
      debugPrint('ML Kit Exception: $e');
      setState(() => _detectedObject = 'Error identifying object');
    }
  }

  // Method to speak the detected object
  Future<void> _speakDetectedObject() async {
    if (_detectedObject != null && _detectedObject!.isNotEmpty) {
      Vibration.vibrate(duration: 100);
      await _flutterTts.speak("it's a $_detectedObject!");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Call _speakDetectedObject after a delay to ensure it happens after state change
    if (_detectedObject != null && _detectedObject!.isNotEmpty && !_isLoading) {
      _speakDetectedObject();
    }

    return Scaffold(
      appBar: AppBar(title: Text('Object Detection')),
      body: SingleChildScrollView( // Make the body scrollable to prevent overflow
        child: Center(
          child: _isLoading
              ? CircularProgressIndicator()
              : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Use a limited height for the image
              SizedBox(
                height: 200, // Adjust the height as necessary
                child: Image.file(File(widget.imagePath), fit: BoxFit.contain),
              ),
              SizedBox(height: 20),
              // Wrap the Text widget with Flexible to prevent overflow
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Flexible(
                  child: Text(
                    _detectedObject ?? 'No object detected',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis, // Prevent overflow
                    maxLines: 3, // Limit to 3 lines
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
