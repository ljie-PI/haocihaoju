import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import 'ocr_service.dart';

class MlKitOcrService implements OcrService {
  MlKitOcrService({TextRecognizer? recognizer})
    : _recognizer =
          recognizer ?? TextRecognizer(script: TextRecognitionScript.chinese);

  final TextRecognizer _recognizer;
  bool _disposed = false;

  @override
  Future<String> recognizeText(String imagePath) async {
    if (_disposed) {
      throw StateError('文字识别服务已关闭，请重启应用后重试。');
    }

    final InputImage inputImage = InputImage.fromFilePath(imagePath);
    final RecognizedText result = await _recognizer.processImage(inputImage);
    final String text = result.text.trim();
    if (text.isEmpty) {
      throw StateError('未识别到文字，请确保图片清晰且包含可读文本。');
    }
    return text;
  }

  @override
  Future<void> dispose() async {
    if (_disposed) {
      return;
    }
    _disposed = true;
    await _recognizer.close();
  }
}
