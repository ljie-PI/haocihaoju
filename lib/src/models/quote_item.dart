import 'dart:convert';

import 'sentence_analysis.dart';

class QuoteItem {
  const QuoteItem({
    required this.id,
    required this.articleText,
    required this.beautifulWords,
    required this.beautifulSentences,
    required this.reflection,
    required this.createdAt,
  });

  final String id;
  final String articleText;
  final List<String> beautifulWords;
  final List<SentenceAnalysis> beautifulSentences;
  final String reflection;
  final DateTime createdAt;

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'quote': beautifulSentences.isEmpty
          ? ''
          : beautifulSentences.first.sentence,
      'analysis': beautifulSentences.isEmpty
          ? ''
          : beautifulSentences.first.whyGood,
      'style_notes': '',
      'article_text': articleText,
      'beautiful_words_json': jsonEncode(beautifulWords),
      'sentence_analyses_json': jsonEncode(
        beautifulSentences
            .map((SentenceAnalysis item) => item.toMap())
            .toList(),
      ),
      'reflection': reflection,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory QuoteItem.fromMap(Map<String, Object?> map) {
    final String wordsJson = (map['beautiful_words_json'] ?? '').toString();
    final String sentenceJson = (map['sentence_analyses_json'] ?? '')
        .toString();

    final List<String> words = _parseWordsJson(wordsJson);
    final List<SentenceAnalysis> sentenceAnalyses = _parseSentenceAnalyses(
      sentenceJson,
    );
    final String reflection = (map['reflection'] ?? '').toString().trim();

    if (sentenceAnalyses.isEmpty) {
      final String quote = (map['quote'] ?? '').toString().trim();
      final String analysis = (map['analysis'] ?? '').toString().trim();
      final String styleNotes = (map['style_notes'] ?? '').toString().trim();
      if (quote.isNotEmpty) {
        sentenceAnalyses.add(
          SentenceAnalysis(
            sentence: quote,
            whyGood: <String>[
              analysis,
              styleNotes,
            ].where((String row) => row.isNotEmpty).join('\n'),
          ),
        );
      }
    }

    return QuoteItem(
      id: map['id']! as String,
      articleText: (map['article_text'] ?? '').toString(),
      beautifulWords: words,
      beautifulSentences: sentenceAnalyses,
      reflection: reflection,
      createdAt: DateTime.parse(map['created_at']! as String),
    );
  }

  static List<String> _parseWordsJson(String value) {
    if (value.trim().isEmpty) {
      return <String>[];
    }
    try {
      final Object? decoded = jsonDecode(value);
      if (decoded is! List<Object?>) {
        return <String>[];
      }
      return decoded
          .map((Object? item) => (item ?? '').toString().trim())
          .where((String item) => item.isNotEmpty)
          .toList();
    } catch (_) {
      return <String>[];
    }
  }

  static List<SentenceAnalysis> _parseSentenceAnalyses(String value) {
    if (value.trim().isEmpty) {
      return <SentenceAnalysis>[];
    }
    try {
      final Object? decoded = jsonDecode(value);
      if (decoded is! List<Object?>) {
        return <SentenceAnalysis>[];
      }
      return decoded
          .whereType<Map<String, Object?>>()
          .map(SentenceAnalysis.fromMap)
          .where(
            (SentenceAnalysis item) =>
                item.sentence.isNotEmpty && item.whyGood.isNotEmpty,
          )
          .toList();
    } catch (_) {
      return <SentenceAnalysis>[];
    }
  }
}
