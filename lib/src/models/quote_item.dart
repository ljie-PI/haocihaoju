import 'dart:convert';

import 'sentence_analysis.dart';
import 'word_analysis.dart';

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
  final List<WordAnalysis> beautifulWords;
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
      'beautiful_words_json': jsonEncode(
        beautifulWords.map((WordAnalysis w) => w.toMap()).toList(),
      ),
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

    final List<WordAnalysis> words = _parseWordsJson(wordsJson);
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

  static List<WordAnalysis> _parseWordsJson(String value) {
    if (value.trim().isEmpty) {
      return <WordAnalysis>[];
    }
    try {
      final Object? decoded = jsonDecode(value);
      if (decoded is! List<Object?>) {
        return <WordAnalysis>[];
      }

      // 尝试解析新格式（WordAnalysis 对象数组）
      try {
        return decoded
            .whereType<Map<String, Object?>>()
            .map(WordAnalysis.fromMap)
            .where(
              (WordAnalysis item) =>
                  item.word.isNotEmpty &&
                  item.definition.isNotEmpty &&
                  item.usage.isNotEmpty,
            )
            .toList();
      } catch (_) {
        // 失败则尝试旧格式（字符串数组），转换为 WordAnalysis
        return decoded
            .map((Object? item) => (item ?? '').toString().trim())
            .where((String item) => item.isNotEmpty)
            .map((String word) => WordAnalysis(
                  word: word,
                  definition: '暂无释义',
                  usage: '暂无用法说明',
                ))
            .toList();
      }
    } catch (_) {
      return <WordAnalysis>[];
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
