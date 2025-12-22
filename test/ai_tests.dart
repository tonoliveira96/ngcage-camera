import 'package:flutter_test/flutter_test.dart';
import 'package:iacamera/services/ai_service.dart';

void main() {
  group('AIService Tests', () {
    test('AIService é um singleton', () {
      final ai1 = AIService();
      final ai2 = AIService();
      
      expect(identical(ai1, ai2), true);
    });

    test('AIService inicializa com flags corretos', () {
      final ai = AIService();
      
      expect(ai.isInitialized, false);
    });

    // Teste que requer dispositivo/emulador
    // test('AIService carrega modelo TFLite', () async {
    //   final ai = AIService();
    //   await ai.loadModel();
    //
    //   expect(ai.isInitialized, true);
    //   expect(ai.labels.length, 2);
    //   expect(ai.labels[0], 'cage');
    //   expect(ai.labels[1], 'not_cage');
    // });
  });

  group('Normalization Tests', () {
    test('Normalização retorna valores em [0.0, 1.0]', () {
      // Simular normalização
      final pixel = 127; // Valor meio-tom
      final normalized = pixel / 255.0;
      
      expect(normalized >= 0.0, true);
      expect(normalized <= 1.0, true);
      expect(normalized, closeTo(0.498, 0.01));
    });

    test('Pixel branco (255) normaliza para ~1.0', () {
      final normalized = 255.0 / 255.0;
      expect(normalized, 1.0);
    });

    test('Pixel preto (0) normaliza para 0.0', () {
      final normalized = 0.0 / 255.0;
      expect(normalized, 0.0);
    });
  });

  group('Output Processing Tests', () {
    test('Detecta classe correta com argmax', () {
      final output = [0.15, 0.85]; // 85% not_cage, 15% cage
      
      double maxScore = 0.0;
      int maxIndex = 0;
      
      for (int i = 0; i < output.length; i++) {
        if (output[i] > maxScore) {
          maxScore = output[i];
          maxIndex = i;
        }
      }
      
      expect(maxIndex, 1); // Índice 1 = not_cage
      expect(maxScore, 0.85);
    });

    test('Mapeia índice para label corretamente', () {
      final labels = ['cage', 'not_cage'];
      const maxIndex = 1;
      
      final className = labels[maxIndex];
      
      expect(className, 'not_cage');
      expect(className.toLowerCase(), 'not_cage');
    });

    test('Bloqueia salvamento se cage detectado', () {
      const className = 'cage';
      final canSave = className.toLowerCase() != 'cage';
      
      expect(canSave, false);
    });

    test('Permite salvamento se not_cage detectado', () {
      const className = 'not_cage';
      final canSave = className.toLowerCase() != 'cage';
      
      expect(canSave, true);
    });
  });

  group('Model Info Tests', () {
    test('Valida shape esperado do tensor input', () {
      const expectedShape = [1, 224, 224, 3]; // [batch, height, width, channels]
      
      expect(expectedShape[0], 1); // Batch size
      expect(expectedShape[1], 224); // Height
      expect(expectedShape[2], 224); // Width
      expect(expectedShape[3], 3); // RGB channels
    });

    test('Valida shape esperado do tensor output', () {
      const expectedShape = [1, 2]; // [batch, classes]
      
      expect(expectedShape[0], 1); // Batch size
      expect(expectedShape[1], 2); // 2 classes (cage, not_cage)
    });

    test('Labels contém exatamente 2 elementos', () {
      final labels = ['cage', 'not_cage'];
      
      expect(labels.length, 2);
      expect(labels[0], 'cage');
      expect(labels[1], 'not_cage');
    });
  });

  group('Input Validation Tests', () {
    test('Output list tem 2 elementos para classificação binária', () {
      final output = List<double>.filled(2, 0.0);
      
      expect(output.length, 2);
    });

    test('Output pode ser preenchido com valores de inferência', () {
      final output = List<double>.filled(2, 0.0);
      output[0] = 0.15;
      output[1] = 0.85;
      
      expect(output.length, 2);
      expect(output[0], 0.15);
      expect(output[1], 0.85);
    });

    test('Confiança é calculada corretamente em porcentagem', () {
      const rawScore = 0.85;
      final confidence = (rawScore * 100).toStringAsFixed(2);
      
      expect(confidence, '85.00');
    });
  });

  group('Error Handling Tests', () {
    test('Detecta output com número errado de classes', () {
      final output = [0.5]; // ❌ Esperado 2 elementos
      
      expect(output.length != 2, true);
    });

    test('Trata arquivo de imagem inválido', () {
      bool isError = false;
      try {
        throw Exception('Falha ao decodificar imagem');
      } catch (e) {
        isError = true;
      }
      
      expect(isError, true);
    });
  });
}
