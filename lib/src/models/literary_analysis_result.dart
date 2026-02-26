import 'sentence_analysis.dart';
import 'word_analysis.dart';

class LiteraryAnalysisResult {
  const LiteraryAnalysisResult({
    required this.beautifulWords,
    required this.beautifulSentences,
    required this.reflection,
  });

  final List<WordAnalysis> beautifulWords;
  final List<SentenceAnalysis> beautifulSentences;
  final String reflection;

  bool get isEmpty {
    return beautifulWords.isEmpty &&
        beautifulSentences.isEmpty &&
        reflection.trim().isEmpty;
  }
}
