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

      // Carrega o modelo TFLite
      _interpreter = await Interpreter.fromAsset(
        'assets/ssd_mobilenet_v2.tflite',
      );

      // Carrega labels e remove linhas vazias
      final labelsData = await rootBundle.loadString('assets/labels.txt');
      _labels = labelsData.split('\n').where((l) => l.isNotEmpty).toList();

      _isModelLoaded = true;
      print('Modelo e labels carregados com sucesso!');
    } catch (e) {
      print('Erro ao carregar modelo ou labels: $e');
      _isModelLoaded = false;
      // Evita tentar fechar interpretador não inicializado
      try {
        _interpreter.close();
      } catch (_) {}
    }
  }

  /// Verifica se o modelo foi carregado
  static bool get isModelLoaded => _isModelLoaded;

  /// Converte imagem para Float32List normalizado
  static Float32List _imageToFloat32List(img.Image image, int inputSize) {
    // Redimensiona a imagem para o tamanho do modelo
    final resized = img.copyResize(image, width: inputSize, height: inputSize);

    // Cria Float32List do tamanho exato [height * width * 3]
    final input = Float32List(inputSize * inputSize * 3);
    int index = 0;

    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        final pixel = resized.getPixel(x, y);
        final r = pixel.r / 255.0;
        final g = pixel.g / 255.0;
        final b = pixel.b / 255.0;

        input[index++] = r;
        input[index++] = g;
        input[index++] = b;
      }
    }

    return input;
  }

  /// Executa detecção na imagem
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

    // Converte imagem para Float32List normalizado
    final inputTensor = _imageToFloat32List(image, 320);

    // Cria mapa de saída dinamicamente
    final outputData = <int, Object>{};
    final outputTensors = _interpreter.getOutputTensors();
    for (var i = 0; i < outputTensors.length; i++) {
      outputData[i] = Float32List.fromList(
        List.filled(outputTensors[i].shape.reduce((a, b) => a * b), 0.0),
      ).reshape(outputTensors[i].shape);
    }

    // Executa inferência
    _interpreter.runForMultipleInputs([
      inputTensor.reshape([1, 320, 320, 3]),
    ], outputData);

    // Processa resultados
    final locations = (outputData[0] as Float32List).reshape([10, 4]);
    final classes = (outputData[1] as Float32List).reshape([10]);
    final scores = (outputData[2] as Float32List).reshape([10]);
    final numberOfDetections = (outputData[3] as Float32List)[0].toInt();

    List<Map<String, dynamic>> results = [];
    for (var i = 0; i < numberOfDetections; i++) {
      if (scores[i] > 0.5) {
        results.add({
          "detectedClass": _labels[classes[i].toInt()],
          "confidenceInClass": scores[i],
          "rect": locations[i],
        });
      }
    }

    return results;
  }
}
