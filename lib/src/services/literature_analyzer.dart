import '../models/excerpt_suggestion.dart';

abstract class LiteratureAnalyzer {
  Future<List<ExcerptSuggestion>> analyzeArticle(String articleText);
}
