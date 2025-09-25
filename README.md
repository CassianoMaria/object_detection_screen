# TFLiteHelper - Detecção de Objetos em Flutter com TensorFlow Lite

Este projeto fornece uma classe utilitária para integrar **TensorFlow Lite** em aplicativos Flutter, permitindo a detecção de objetos em imagens usando o modelo **SSD MobileNet V2**.

---

## Funcionalidades

- Carrega modelos `.tflite` e labels `.txt` de forma segura.
- Converte imagens em **tensors normalizados** compatíveis com o modelo.
- Executa inferência no dispositivo usando Flutter (sem necessidade de internet).
- Retorna detecções com:
  - Classe detectada
  - Confiança da detecção
  - Coordenadas do retângulo delimitador (bounding box)

---

## Estrutura do Projeto

assets/
├── ssd_mobilenet_v2.tflite # Modelo TFLite
└── labels.txt # Labels/classes do modelo

lib/
└── tflite_helper.dart # Classe utilitária para inferência

yaml
Copiar código

---

## Instalação

1. Adicione dependências no `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  tflite_flutter: ^0.10.0
  image: ^4.0.17
Adicione os assets no pubspec.yaml:

yaml
Copiar código
flutter:
  assets:
    - assets/ssd_mobilenet_v2.tflite
    - assets/labels.txt
Execute:

bash
Copiar código
flutter pub get
Uso
dart
Copiar código
import 'package:seu_projeto/tflite_helper.dart';

void main() async {
  // Carrega o modelo e labels
  await TFLiteHelper.loadModel();

  if (TFLiteHelper.isModelLoaded) {
    // Executa detecção em uma imagem
    final results = await TFLiteHelper.runModelOnImage('assets/test_image.jpg');

    if (results != null) {
      for (var r in results) {
        print('Classe: ${r["detectedClass"]}');
        print('Confiança: ${r["confidenceInClass"]}');
        print('Bounding box: ${r["rect"]}');
      }
    }
  }
}
Observações
O modelo SSD MobileNet V2 espera imagens de tamanho 320x320.

As cores da imagem são normalizadas entre 0 e 1.

Apenas detecções com confiança maior que 0.5 são retornadas por padrão.

Funciona 100% offline, sem necessidade de APIs externas.

Referências
TensorFlow Lite Flutter

SSD MobileNet V2

Package image

Licença
Este projeto está sob a licença MIT.