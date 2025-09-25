import 'package:flutter/material.dart';
import 'package:object_detection_app/tflite_helper.dart';
import 'object_detection_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TFLiteHelper.loadModel();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Detecção de Objetos',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ObjectDetectionScreen(),
    );
  }
}