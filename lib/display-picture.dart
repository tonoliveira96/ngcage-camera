import 'dart:io';

import 'package:flutter/material.dart';
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Imagem salva em: $newPath')),
        );
      }
    } catch (e) {
      // Mostrar mensagem de erro
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar imagem: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Imagem")),
      body: Column(
        children: [
          Center(child: Image.file((File(imagePath)))),
          Center(
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white, 
                textStyle: const TextStyle(fontSize: 20),
              ),
              onPressed: () => _saveImage(context), 
              child: Text("Salvar")),
          ),
        ],
      ),
    );
  }
}
