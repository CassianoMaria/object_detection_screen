import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:object_detection_app/tflite_helper.dart';

class ObjectDetectionScreen extends StatefulWidget {
  const ObjectDetectionScreen({super.key});

  @override
  State<ObjectDetectionScreen> createState() => _ObjectDetectionScreenState();
}

class _ObjectDetectionScreenState extends State<ObjectDetectionScreen> {
  File? _image;
  List<dynamic>? _results;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    setState(() {
      _isLoading = true;
      _results = null;
    });

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });

        if (TFLiteHelper.isModelLoaded) {
          final res = await TFLiteHelper.runModelOnImage(pickedFile.path);
          setState(() {
            _results = res;
          });
        } else {
          print("Erro: O modelo não foi carregado. Verifique os assets e o main.dart.");
          setState(() {
            _results = [];
          });
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Erro ao executar o modelo: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detecção de Objetos"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: _image == null
                    ? const Text(
                        "Nenhuma imagem selecionada.",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      )
                    : Image.file(_image!),
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : _results != null && _results!.isNotEmpty
                    ? Expanded(
                        child: ListView.builder(
                          itemCount: _results!.length,
                          itemBuilder: (context, index) {
                            var result = _results![index];
                            return ListTile(
                              title: Text(
                                "${result["detectedClass"]}",
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                "Confiança: ${(result["confidenceInClass"] * 100).toStringAsFixed(2)}%",
                              ),
                            );
                          },
                        ),
                      )
                    : _results != null && _results!.isEmpty
                        ? const Text("Nenhum objeto detectado.", style: TextStyle(color: Colors.red))
                        : Container(),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _pickImage,
              icon: const Icon(Icons.image),
              label: const Text("Selecionar Imagem"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}