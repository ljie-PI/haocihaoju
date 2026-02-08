import 'dart:convert';

import '../models/excerpt_suggestion.dart';
import 'heuristic_excerpt_picker.dart';
import 'llm_client.dart';

class MockLlmClient implements LlmClient {
  @override
  Future<String> complete(String prompt) async {
    final String articleText = _extractArticleText(prompt);
    final List<ExcerptSuggestion> suggestions = pickHeuristicExcerpts(articleText, maxItems: 5);
    final List<Map<String, String>> payload = suggestions
        .map(
          (ExcerptSuggestion item) => <String, String>{
            'quote': item.quote,
            'analysis': item.analysis,
            'style_notes': item.styleNotes,
          },
        )
        .toList();

    return jsonEncode(<String, Object?>{'items': payload});
  }

  String _extractArticleText(String prompt) {
    const String marker = 'ARTICLE_START\n';
    final int index = prompt.indexOf(marker);
    if (index == -1) {
      return prompt;
    }
    return prompt.substring(index + marker.length).trim();
  }
}
