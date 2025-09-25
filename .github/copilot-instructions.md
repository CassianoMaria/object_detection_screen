# Copilot Instructions for `object_detection_app`

## Visão Geral
Este projeto é um aplicativo Flutter para detecção de objetos usando modelos TensorFlow Lite (TFLite). O fluxo principal envolve carregar um modelo `.tflite` e um arquivo de labels, processar imagens e exibir resultados de detecção.

## Estrutura e Componentes Principais
- **lib/main.dart**: Ponto de entrada do app Flutter.
- **lib/object_detection_screen.dart**: Tela principal de detecção de objetos.
- **lib/tflite_helper.dart**: Lógica de carregamento do modelo, pré-processamento de imagens e inferência TFLite.
- **assets/ssd_mobilenet_v2.tflite**: Modelo TFLite usado para detecção.
- **assets/labels.txt**: Labels das classes detectadas.

## Convenções e Padrões Específicos
- O modelo e labels são carregados via `TFLiteHelper.loadModel()`. Labels devem estar em `assets/labels.txt` e o modelo em `assets/ssd_mobilenet_v2.tflite`.
- O pré-processamento de imagens redimensiona para 300x300 e normaliza os pixels para [0,1].
- A inferência retorna uma lista de mapas com: `detectedClass`, `confidenceInClass` e `rect` (bounding box).
- O threshold de confiança padrão é 0.5.

## Fluxos de Desenvolvimento
- **Build/Run**: Use comandos padrão Flutter (`flutter run`, `flutter build apk`, etc.).
- **Testes**: Testes de widget em `test/widget_test.dart` (padrão Flutter).
- **Adição de assets**: Sempre declare novos arquivos em `pubspec.yaml` na seção `flutter/assets`.
- **Dependências**: Gerenciadas via `pubspec.yaml`. Use `flutter pub get` após alterações.

## Integrações e Dependências
- Principais pacotes: `tflite_flutter`, `image`, `image_picker`, `tflite_flutter_helper`.
- O app depende de assets locais, não de downloads dinâmicos.

## Exemplos de Uso
```dart
await TFLiteHelper.loadModel();
final results = await TFLiteHelper.runModelOnImage(path);
```

## Observações
- O projeto segue padrões Flutter/Dart convencionais, mas a lógica de inferência está centralizada em `tflite_helper.dart`.
- Para adicionar novos modelos, coloque o `.tflite` e labels em `assets/` e ajuste o nome no helper.
- Para builds multiplataforma, mantenha dependências e assets sincronizados em `pubspec.yaml`.

---
Seções incompletas ou dúvidas? Peça exemplos de fluxos, padrões de código ou integração de novos modelos.
