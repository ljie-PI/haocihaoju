abstract class OcrService {
  Future<String> recognizeText(String imagePath);

  Future<void> dispose() async {}
}
