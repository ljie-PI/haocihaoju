class ScannedPage {
  const ScannedPage({
    required this.id,
    required this.pageNumber,
    required this.imagePath,
    required this.extractedText,
  });

  final String id;
  final int pageNumber;
  final String imagePath;
  final String extractedText;
}
