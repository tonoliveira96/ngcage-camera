import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:iacamera/display-picture.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraScreen extends StatefulWidget{
  final List<CameraDescription> cameras;

  const CameraScreen({
    super.key, 
    required this.cameras, 
  });

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController controller;
  int selectedCameraIndex = 0;
  bool isInitialized = false;
  bool permissionGranted = false;

  @override
  void initState(){
    super.initState();
    requestCameraPermission();
  }

  Future<void> requestCameraPermission() async{
    final status = await Permission.camera.request();

    if(status.isGranted){
      permissionGranted= true;
      initializeCamera(selectedCameraIndex);
    }else{
      setState(() {
        permissionGranted= false;
      });
    }
  }

  void initializeCamera(int index) async {
    if (widget.cameras.isEmpty) return;

    controller = CameraController(widget.cameras[index], ResolutionPreset.medium);

    try{
      await controller.initialize();
      setState(() {
        isInitialized = true;
        selectedCameraIndex = index;
      });
    }catch(e){
      print("Camera rejected");
    }
  }

  Future<void> takePicture(BuildContext context)async{
    if(!controller.value.isInitialized) return;

    final directory = await getExternalStorageDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final path = join(directory!.path,'IMG_$timestamp.png');
    await File(path).create(recursive: true);

     try {
      final file = await controller.takePicture();
      await file.saveTo(path);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DisplayPictureScreen(imagePath: path),
        ),
      );
    } catch (e) {
      print('Error taking picture: $e');
    }
  }

  void switchCamera() async {
    final newIndex = (selectedCameraIndex + 1) % widget.cameras.length;
    setState(() {
      isInitialized= false;
    });

    await controller.dispose();
    initializeCamera(newIndex);
  }
  
  @override
  void dispose(){
    if(controller.value.isInitialized){
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    if(!permissionGranted){
      return Scaffold(
        body: Center(
          child: Text('Please grant camera permission!'),
        ),
      );
    }

    if(!isInitialized){
      return Scaffold(
       body: Center(
          child: CircularProgressIndicator()
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter IA Camera'),
        actions: [
          IconButton(onPressed: switchCamera, icon: Icon(Icons.switch_camera))
        ],
      ),
      body:SafeArea(child: Stack(
        children: [
          SizedBox.expand(
            child: CameraPreview(controller),
          ),
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Center(
            child: Center(
              child: IconButton(onPressed: ()=> takePicture(context), icon: Icon(Icons.camera, size: 80, color: Colors.white,)),
            ) ,
          ))
        ],
      )) ,
    );
  }
}
