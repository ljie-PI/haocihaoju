import '../models/literary_analysis_result.dart';

abstract class LiteratureAnalyzer {
  Future<LiteraryAnalysisResult> analyzeArticle(String articleText);
}
