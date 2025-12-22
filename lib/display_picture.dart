import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;
  final Interpreter? interpreter;
  final List<String>? labels;

  const DisplayPictureScreen({
    super.key,
    required this.imagePath,
    this.interpreter,
    this.labels,
  });

  @override
  State<DisplayPictureScreen> createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  bool _isAnalyzing = false;
  Map<String, dynamic>? _analysisResult;

  @override
  void initState() {
    super.initState();
    if (widget.interpreter != null) {
      _analyzeImage();
    }
  }

  Future<void> _analyzeImage() async {
    if (widget.interpreter == null) {
      setState(() {
        _analysisResult = {
          'success': false,
          'error': 'Modelo de IA não disponível',
        };
      });
      return;
    }

    setState(() {
      _isAnalyzing = true;
    });

    try {
      // Ler a imagem do arquivo
      final File imageFile = File(widget.imagePath);
      final Uint8List imageBytes = await imageFile.readAsBytes();


      // Decodificar a imagem
      img.Image? image = img.decodeImage(imageBytes);
      if (image == null) {
        throw Exception('Falha ao decodificar imagem');
      }

      // Redimensionar para 224x224 (padrão MobileNet)
      img.Image resizedImage = img.copyResize(image, width: 224, height: 224);

      // Normalizar a imagem para [0.0, 1.0]
      var input = _normalizeImage(resizedImage);

      // Preparar output: 2 classes (cage vs not_cage)
      var output = List<double>.filled(2, 0.0);
      var outputList = [output];

      // Executar inferência
      widget.interpreter!.run(input, outputList);

      // Processar resultados
      final results = _processResults(outputList[0]);

      setState(() {
        _analysisResult = {
          'success': true,
          'topClass': results['topClass'],
          'topClassName': results['topClassName'],
          'topScore': results['topScore'],
          'allResults': results['results'],
        };
      });
    } catch (e) {
      debugPrint('❌ Erro ao analisar imagem: $e');
      setState(() {
        _analysisResult = {
          'success': false,
          'error': 'Erro ao processar imagem: $e',
        };
      });
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  /// Normaliza a imagem para o intervalo [0.0, 1.0]
  /// Formato: [1, 224, 224, 3] (NHWC - Batch, Height, Width, Channels)
  List<List<List<List<double>>>> _normalizeImage(img.Image image) {
    var input = List.generate(
      1,
      (i) => List.generate(
        224,
        (j) => List.generate(
          224,
          (k) => List.generate(3, (l) {
            final pixel = image.getPixel(k, j);
            // Valores RGB como double
            final channels = [
              pixel.r.toDouble(),
              pixel.g.toDouble(),
              pixel.b.toDouble(),
            ];
            // Normalizar para [0.0, 1.0] - padrão MobileNetV2
            return channels[l] / 255.0;
          }),
        ),
      ),
    );
    return input;
  }

  Map<String, dynamic> _processResults(List<double> output) {
    // Validação: o modelo foi treinado com 2 classes (cage, not_cage)
    if (output.length != 2) {
      debugPrint(
        "⚠️ AVISO: Saída esperada para 2 classes, mas recebeu ${output.length}",
      );
    }

    // Encontrar a classe com maior confiança
    double maxScore = 0.0;
    int maxIndex = 0;

    for (int i = 0; i < output.length; i++) {
      if (output[i] > maxScore) {
        maxScore = output[i];
        maxIndex = i;
      }
    }

    // Obter label correspondente
    String? className;
    if (maxIndex < widget.labels!.length) {
      className = widget.labels![maxIndex];
    } else {
      className = "Classe $maxIndex";
    }

    // Ordenar resultados por confiança
    final List<MapEntry<int, double>> indexed = output.asMap().entries.toList();
    indexed.sort((a, b) => b.value.compareTo(a.value));

    // Top 5 resultados (ou todos, se menos de 5)
    final topResults = indexed.take(5).map((e) {
      final label = e.key < widget.labels!.length
          ? widget.labels![e.key]
          : "Classe ${e.key}";
      return {
        'index': e.key,
        'label': label,
        'rawScore': e.value,
        'confidence': (e.value * 100).toStringAsFixed(2),
      };
    }).toList();

    debugPrint("🎯 Resultado da Inferência:");
    debugPrint("   Classe detectada: $className (índice $maxIndex)");
    debugPrint("   Confiança: ${(maxScore * 100).toStringAsFixed(2)}%");
    debugPrint("   Scores brutos: $output");

    return {
      'topClass': maxIndex,
      'topClassName': className,
      'topScore': (maxScore * 100).toStringAsFixed(2),
      'results': topResults,
    };
  }

  bool _canSavePicture() {
    // Só permite salvar se análise foi bem-sucedida e não é 'cage'
    if (_analysisResult == null || _analysisResult!['success'] == true) {
      return true; // Permite salvar se não houve análise (falha safe)
    }

    final className = (_analysisResult!['topClassName'] ?? '').toLowerCase();
    return className == 'cage';
  }

  Future<void> _savePicture() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final String fileName = 'IMG_$timestamp.png';
      final File destFile = File('${directory.path}/$fileName');

      await File(widget.imagePath).copy(destFile.path);

      Fluttertoast.showToast(
        msg: 'Imagem salva com sucesso!',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Erro ao salvar imagem: $e',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.amberAccent),
        title: Text("Imagem", style: TextStyle(color: Colors.amberAccent)),
      ),
      body: Column(
        children: [
          Expanded(child: Image.file(File(widget.imagePath))),
          if (widget.interpreter != null) ...[
            if (_isAnalyzing)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 8),
                    const Text('Analisando imagem...'),
                  ],
                ),
              )
            else if (_analysisResult != null)
              _buildAnalysisResult()
            else
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Nenhuma análise realizada'),
              ),
          ],
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _canSavePicture() ? null: _savePicture,
              style: ElevatedButton.styleFrom(
                backgroundColor: _canSavePicture() ? Colors.blue : Colors.grey,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text(
                _canSavePicture()
                    ? 'Salvar Foto'
                    : 'Não é seguro salvar (Sem Cage detectado)',
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisResult() {
    if (_analysisResult!['success'] == false) {
      return Container(
        color: Colors.red[100],
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Erro na Análise',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(_analysisResult!['error'] ?? 'Erro desconhecido'),
          ],
        ),
      );
    }

    final className = _analysisResult!['topClassName'] ?? 'Desconhecido';
    final isCage = className.toLowerCase() == 'cage';

    final color = isCage ? Colors.green : Colors.red;

    return Container(
      color: color[50],
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho com resultado principal
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Resultado da Detecção',
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      className.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_analysisResult!['topScore']}%',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Status textual
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color, width: 1),
            ),
            child: Row(
              children: [
                Icon(
                  isCage ? Icons.check_circle : Icons.warning,
                  color: color,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isCage
                        ? 'Cage detectado - Seguro salvar'
                        : 'Sem Cage - Não salvar',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: color[900],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
