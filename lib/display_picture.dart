import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;
  const DisplayPictureScreen({super.key, required this.imagePath});

  Future<void> _saveImage(BuildContext context) async {
    try {
      // Obter o diretório de documentos do dispositivo
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String fileName = path.basename(imagePath);
      final String newPath = path.join(appDir.path, fileName);

      // Copiar a imagem para o novo diretório
      final File sourceFile = File(imagePath);
      await sourceFile.copy(newPath);

      // Mostrar mensagem de sucesso
      if (context.mounted) {
        Fluttertoast.showToast(
          msg: 'Imagem salva na galeria!',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.green.withAlpha(128),
          textColor: Colors.white,
        );
      }
    } catch (e) {
      // Mostrar mensagem de erro
      if (context.mounted) {
        Fluttertoast.showToast(
          msg: 'Erro ao salvar imagem: $e',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red.withAlpha(128),
          textColor: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black45,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.amberAccent),
        title: Text("Imagem", style: TextStyle(color: Colors.amberAccent)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.amberAccent,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontSize: 20),
              ),
              onPressed: () => _saveImage(context),
              child: Text("Salvar"),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsetsGeometry.all(10),
              child: Center(
                child: Text("É ele!", style: TextStyle(fontSize: 20)),
              ),
            ),
            Center(child: Image.file((File(imagePath)))),
          ],
        ),
      ),
    );
  }
}
