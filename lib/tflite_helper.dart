import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class TFLiteHelper {
  static late Interpreter _interpreter;
  static late List<String> _labels;
  static bool _isModelLoaded = false;

  /// Carrega o modelo e os labels
  static Future<void> loadModel() async {
    try {
      if (_isModelLoaded) return;
      _interpreter = await Interpreter.fromAsset(
        'assets/ssd_mobilenet_v2.tflite',
      );
      final labelsData = await rootBundle.loadString('assets/labels.txt');
      _labels = labelsData.split('\n');
      _isModelLoaded = true;
      print('Modelo e labels carregados com sucesso!');
    } catch (e) {
      print('Erro ao carregar modelo ou labels: $e');
      _isModelLoaded = false;
      _interpreter.close();
    }

    // Fim da classe TFLiteHelper
  }

  /// Verifica se o modelo foi carregado
  static bool get isModelLoaded => _isModelLoaded;

  /// Executa detecção na imagem
  // ... (dentro da classe TFLiteHelper)
  // ... (inside the TFLiteHelper class)
  static Future<List<Map<String, dynamic>>?> runModelOnImage(
    String path,
  ) async {
    if (!_isModelLoaded) {
      print('O modelo não foi carregado.');
      return null;
    }

    // Lê e decodifica a imagem
    final imageBytes = File(path).readAsBytesSync();
    final image = img.decodeImage(imageBytes);
    if (image == null) return null;

    // Redimensiona a imagem para o tamanho de entrada do modelo (320x320)
    final resizedImage = img.copyResize(image, width: 320, height: 320);
    final inputTensor = Uint8List(1 * 320 * 320 * 3);
    int pixelIndex = 0;

    // Converte os pixels da imagem para Uint8 (0-255)
    for (int y = 0; y < resizedImage.height; y++) {
      for (int x = 0; x < resizedImage.width; x++) {
        final pixel = resizedImage.getPixel(x, y);
        inputTensor[pixelIndex++] = pixel.r.toInt();
        inputTensor[pixelIndex++] = pixel.g.toInt();
        inputTensor[pixelIndex++] = pixel.b.toInt();
      }
    }

    // Define os tensores de saída com base no erro de dimensão
    final outputData = <int, Object>{};

    // O modelo retornou: [1, 12804, 4] para boxes.
    // Isso indica que o modelo é um modelo raw.
    final boxesShape = [1, 12804, 4];
    final classesShape = [1, 12804];
    final scoresShape = [1, 12804];
    final numDetectionsShape = [1];

    // Aloca o espaço para cada tensor de saída
    outputData[0] = Float32List(
      boxesShape.reduce((a, b) => a * b),
    ).reshape(boxesShape);
    outputData[1] = Float32List(
      classesShape.reduce((a, b) => a * b),
    ).reshape(classesShape);
    outputData[2] = Float32List(
      scoresShape.reduce((a, b) => a * b),
    ).reshape(scoresShape);
    outputData[3] = Float32List(
      numDetectionsShape.reduce((a, b) => a * b),
    ).reshape(numDetectionsShape);

    // Executa a inferência
    _interpreter.runForMultipleInputs([
      inputTensor.reshape([1, 320, 320, 3]),
    ], outputData);

    // Processa resultados
    // As saídas do modelo agora são muito maiores
    final locations = (outputData[0] as Float32List).reshape([12804, 4]);
    final classes = (outputData[1] as Float32List).reshape([12804]);
    final scores = (outputData[2] as Float32List).reshape([12804]);

    List<Map<String, dynamic>> results = [];

    // O número de detecções não é retornado diretamente, então iteramos sobre todas
    // as 12804 predições e aplicamos um filtro de confiança.
    for (var i = 0; i < scores.length; i++) {
      if (scores[i] > 0.5) {
        final int classIndex = classes[i].toInt();
        if (classIndex >= 1 && classIndex < _labels.length) {
          results.add({
            "detectedClass": _labels[classIndex],
            "confidenceInClass": scores[i],
            "rect": locations[i],
          });
        }
      }
    }
    return results;
  }
}
