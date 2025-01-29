import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'object.dart';
import 'package:vibration/vibration.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  CameraPageState createState() => CameraPageState();
}

class CameraPageState extends State<CameraPage> {
  CameraController? _cameraController;
  late List<CameraDescription> _cameras;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      _cameraController = CameraController(
        _cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.back),
        ResolutionPreset.high,
      );
      await _cameraController!.initialize();
      setState(() => _isInitialized = true);
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _capturePhoto() async {
    Vibration.vibrate(duration: 100);
    try {
      if (!_cameraController!.value.isInitialized || _cameraController!.value.isTakingPicture) {
        return;
      }
      final XFile photo = await _cameraController!.takePicture();

      if (!mounted) return; // Ensure the widget is still in the widget tree

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ObjectPage(imagePath: photo.path),
        ),
      );
    } catch (e) {
      debugPrint('Error capturing photo: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: _capturePhoto,
        child: _isInitialized
            ? CameraPreview(_cameraController!)
            : Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
