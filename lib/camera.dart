import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iacamera/display_picture.dart';
import 'package:iacamera/services/ai_service.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const CameraScreen({super.key, required this.cameras});

  @override
  CameraScreenState createState() => CameraScreenState();
}

class CameraScreenState extends State<CameraScreen> {
  late CameraController controller;
  int selectedCameraIndex = 0;
  bool isInitialized = false;
  bool permissionGranted = false;
  bool _aiInitialized = false;
  final AIService _aiService = AIService();

  @override
  void initState() {
    super.initState();
    requestCameraPermission();
    _checkAIStatus();
  }

  Future<void> _checkAIStatus() async {
    if (mounted) {
      setState(() {
        _aiInitialized = _aiService.isInitialized;
      });
    }
  }

  Future<void> requestCameraPermission() async {
    final status = await Permission.camera.request();

    if (status.isGranted) {
      permissionGranted = true;
      initializeCamera(selectedCameraIndex);
    } else {
      setState(() {
        permissionGranted = false;
      });
    }
  }

  void initializeCamera(int index) async {
    if (widget.cameras.isEmpty) return;

    controller = CameraController(
      widget.cameras[index],
      ResolutionPreset.medium,
    );

    try {
      await controller.initialize();
      if (mounted) {
        setState(() {
          isInitialized = true;
          selectedCameraIndex = index;
        });
      }
    } catch (e) {
      debugPrint('Erro ao inicializar câmera: $e');
    }
  }

  Future<void> takePicture(BuildContext context) async {
    if (!controller.value.isInitialized || !mounted) return;

    final directory = await getExternalStorageDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final path = join(directory!.path, 'IMG_$timestamp.png');
    await File(path).create(recursive: true);

    try {
      final file = await controller.takePicture();
      await file.saveTo(path);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DisplayPictureScreen(
              imagePath: path,
              interpreter: _aiInitialized ? _aiService.interpreter : null,
              labels: _aiInitialized ? _aiService.labels : null,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error taking picture: $e');
      Fluttertoast.showToast(
        msg: 'Erro ao capturar imagem: $e',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  void switchCamera() async {
    final newIndex = (selectedCameraIndex + 1) % widget.cameras.length;
    setState(() {
      isInitialized = false;
    });

    await controller.dispose();
    initializeCamera(newIndex);
  }

  @override
  void dispose() {
    try {
      if (controller.value.isInitialized) {
        controller.dispose();
      }
    } catch (e) {
      debugPrint('Erro ao liberar câmera: $e');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!permissionGranted) {
      return Scaffold(
        body: Center(child: Text('Please grant camera permission!')),
      );
    }

    if (!isInitialized) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: _aiInitialized
            ? Text(
                'IA Ativa',
                style: TextStyle(color: Colors.greenAccent, fontSize: 14),
              )
            : Text(
                'IA Inativa',
                style: TextStyle(color: Colors.orangeAccent, fontSize: 14),
              ),
        actions: [
          IconButton(
            onPressed: switchCamera,
            icon: Icon(Icons.switch_camera, color: Colors.amberAccent),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SizedBox.expand(child: CameraPreview(controller)),
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: Center(
                child: Center(
                  child: IconButton(
                    onPressed: () => takePicture(context),
                    icon: Icon(
                      Icons.camera,
                      size: 80,
                      color: Colors.amberAccent,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
