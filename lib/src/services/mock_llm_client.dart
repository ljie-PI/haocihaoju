import 'dart:convert';

import 'heuristic_excerpt_picker.dart';
import 'llm_client.dart';

class MockLlmClient implements LlmClient {
  @override
  Future<String> complete(String prompt) async {
    final String articleText = _extractArticleText(prompt);
    final analysis = pickHeuristicAnalysis(articleText);

    return jsonEncode(<String, Object?>{
      'beautiful_words': analysis.beautifulWords,
      'beautiful_sentences': analysis.beautifulSentences
          .map(
            (item) => <String, String>{
              'sentence': item.sentence,
              'why_good': item.whyGood,
            },
          )
          .toList(),
      'reflection': analysis.reflection,
    });
  }

  String _extractArticleText(String prompt) {
    const String marker = 'ARTICLE_START';
    const String endMarker = 'ARTICLE_END';
    final int index = prompt.indexOf(marker);
    if (index == -1) {
      return prompt;
    }
    final String afterStart = prompt.substring(index + marker.length).trim();
    final int endIndex = afterStart.indexOf(endMarker);
    if (endIndex == -1) {
      return afterStart.trim();
    }
    return afterStart.substring(0, endIndex).trim();
  }
}
