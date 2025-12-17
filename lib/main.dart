import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:iacamera/camera.dart';

List<CameraDescription> _cameras = [];
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.black) 
      ),
      home: CameraScreen(cameras: _cameras),
    );
  }
}




