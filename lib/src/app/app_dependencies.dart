import '../data/quote_repository.dart';
import '../services/literature_analyzer.dart';
import '../services/ocr_service.dart';

class AppDependencies {
  const AppDependencies({
    required this.quoteRepository,
    required this.ocrService,
    required this.literatureAnalyzer,
  });

  final QuoteRepository quoteRepository;
  final OcrService ocrService;
  final LiteratureAnalyzer literatureAnalyzer;
}
