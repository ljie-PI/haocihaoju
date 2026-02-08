import 'dart:convert';

import '../models/excerpt_suggestion.dart';
import 'heuristic_excerpt_picker.dart';
import 'literature_analyzer.dart';
import 'llm_client.dart';

class LlmLiteratureAnalyzer implements LiteratureAnalyzer {
  LlmLiteratureAnalyzer({
    required LlmClient client,
  }) : _client = client;

  final LlmClient _client;

  @override
  Future<List<ExcerptSuggestion>> analyzeArticle(String articleText) async {
    if (articleText.trim().isEmpty) {
      return <ExcerptSuggestion>[];
    }

    final String prompt = _buildPrompt(articleText);
    try {
      final String rawResponse = await _client.complete(prompt);
      final Object? decoded = jsonDecode(rawResponse);

      if (decoded is! Map<String, Object?> || decoded['items'] is! List<Object?>) {
        return pickHeuristicExcerpts(articleText);
      }

      final List<Object?> rawItems = decoded['items']! as List<Object?>;
      final List<ExcerptSuggestion> items = rawItems
          .whereType<Map<String, Object?>>()
          .map((Map<String, Object?> row) {
            final String quote = (row['quote'] ?? '').toString().trim();
            final String analysis = (row['analysis'] ?? '').toString().trim();
            final String styleNotes = (row['style_notes'] ?? '').toString().trim();
            if (quote.isEmpty || analysis.isEmpty || styleNotes.isEmpty) {
              return null;
            }
            return ExcerptSuggestion(
              quote: quote,
              analysis: analysis,
              styleNotes: styleNotes,
            );
          })
          .whereType<ExcerptSuggestion>()
          .toList();

      if (items.isEmpty) {
        return pickHeuristicExcerpts(articleText);
      }
      return items;
    } catch (_) {
      return pickHeuristicExcerpts(articleText);
    }
  }

  String _buildPrompt(String articleText) {
    return '''
You are a Chinese literature assistant.
Extract 3-8 excellent words or sentences from the article and analyze each quote with full-context literary commentary.
Return strict JSON with this format:
{"items":[{"quote":"...","analysis":"...","style_notes":"..."}]}
Do not return markdown.
ARTICLE_START
$articleText
''';
  }
}
