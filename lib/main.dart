import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:iacamera/camera.dart';
import 'package:iacamera/services/ai_service.dart';

List<CameraDescription> _cameras = [];
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Carregar modelo de IA antes das câmeras
  try {
    await AIService().loadModel();
  } catch (e) {
    debugPrint('⚠️ Erro ao carregar modelo: $e');
  }
  
  _cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black45),
      ),
      home: CameraScreen(cameras: _cameras),
    );
  }
}




