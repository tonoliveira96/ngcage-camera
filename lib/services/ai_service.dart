import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class AIService {
  static final AIService _instance = AIService._internal();
  late Interpreter interpreter;
  late List<String> labels;
  bool _isInitialized = false;

  factory AIService() {
    return _instance;
  }

  AIService._internal();

  Future<void> loadModel() async {
    try {
      // Carregar modelo TFLite
      interpreter = await Interpreter.fromAsset(
        'assets/models/ncage.tflite',
      );
      final labelsData = await rootBundle.loadString('assets/models/labels.txt');
      labels = labelsData
          .split('\n')
          .where((label) => label.trim().isNotEmpty)
          .toList();

      _isInitialized = true;
    } catch (e) {
      debugPrint(" Erro ao carregar modelo: $e");
      _isInitialized = false;
      rethrow;
    }
  }

  bool get isInitialized => _isInitialized;

  void dispose() {
    if (_isInitialized) {
      interpreter.close();
      _isInitialized = false;
      debugPrint("🔒 Modelo liberado da memória");
    }
  }
}
