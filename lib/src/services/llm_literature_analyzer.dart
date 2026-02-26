import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/literary_analysis_result.dart';
import '../models/sentence_analysis.dart';
import '../models/word_analysis.dart';
import 'literature_analyzer.dart';
import 'llm_client.dart';

class LlmLiteratureAnalyzer implements LiteratureAnalyzer {
  LlmLiteratureAnalyzer({
    required LlmClient client,
    String promptAssetPath = 'assets/prompts/literary_analysis_prompt.txt',
  }) : _client = client,
       _promptAssetPath = promptAssetPath;

  final LlmClient _client;
  final String _promptAssetPath;
  String? _cachedPromptTemplate;

  @override
  Future<LiteraryAnalysisResult> analyzeArticle(String articleText) async {
    if (articleText.trim().isEmpty) {
      return const LiteraryAnalysisResult(
        beautifulWords: <WordAnalysis>[],
        beautifulSentences: <SentenceAnalysis>[],
        reflection: '',
      );
    }

    final String prompt = await _buildPrompt(articleText);
    final String rawResponse = await _client.complete(prompt);
    final LiteraryAnalysisResult result = _parseResult(rawResponse);
    if (_isValidResult(result)) {
      return result;
    }
    throw Exception(
      'AI 解析结果不完整，请重试。可能原因：词语少于10个、句子少于5条或读后感为空。',
    );
  }

  bool _isValidResult(LiteraryAnalysisResult result) {
    if (result.beautifulWords.length < 10) {
      return false;
    }
    if (result.beautifulSentences.length < 5) {
      return false;
    }
    return result.reflection.trim().isNotEmpty;
  }

  Future<String> _buildPrompt(String articleText) async {
    final String template = await _loadPromptTemplate();
    return template.replaceAll('{{article_text}}', articleText);
  }

  Future<String> _loadPromptTemplate() async {
    final String? cached = _cachedPromptTemplate;
    if (cached != null && cached.trim().isNotEmpty) {
      return cached;
    }
    final String loaded = await rootBundle.loadString(_promptAssetPath);
    _cachedPromptTemplate = loaded;
    return loaded;
  }

  LiteraryAnalysisResult _parseResult(String rawResponse) {
    final Object? decoded = _decodeJsonSafely(rawResponse);
    if (decoded is! Map<String, Object?>) {
      throw const FormatException('LLM 返回格式错误');
    }

    final List<WordAnalysis> beautifulWords = _extractWords(
      decoded['beautiful_words'],
    );
    final List<SentenceAnalysis> beautifulSentences = _extractSentences(
      decoded['beautiful_sentences'],
    );
    final String reflection = (decoded['reflection'] ?? '').toString().trim();

    return LiteraryAnalysisResult(
      beautifulWords: beautifulWords,
      beautifulSentences: beautifulSentences,
      reflection: reflection,
    );
  }

  List<WordAnalysis> _extractWords(Object? rawWords) {
    if (rawWords is! List<Object?>) {
      return <WordAnalysis>[];
    }
    return rawWords
        .whereType<Map<String, Object?>>()
        .map((Map<String, Object?> row) {
          final String word = (row['word'] ?? '').toString().trim();
          final String definition = (row['definition'] ?? '').toString().trim();
          final String usage = (row['usage'] ?? '').toString().trim();
          if (word.isEmpty || definition.isEmpty || usage.isEmpty) {
            return null;
          }
          return WordAnalysis(word: word, definition: definition, usage: usage);
        })
        .whereType<WordAnalysis>()
        .toList();
  }

  List<SentenceAnalysis> _extractSentences(Object? rawSentences) {
    if (rawSentences is! List<Object?>) {
      return <SentenceAnalysis>[];
    }

    return rawSentences
        .whereType<Map<String, Object?>>()
        .map((Map<String, Object?> row) {
          final String sentence = (row['sentence'] ?? '').toString().trim();
          final String whyGood = (row['why_good'] ?? '').toString().trim();
          if (sentence.isEmpty || whyGood.isEmpty) {
            return null;
          }
          return SentenceAnalysis(sentence: sentence, whyGood: whyGood);
        })
        .whereType<SentenceAnalysis>()
        .toList();
  }

  Object? _decodeJsonSafely(String rawResponse) {
    final String trimmed = rawResponse.trim();
    try {
      return jsonDecode(trimmed);
    } catch (_) {
      final int start = trimmed.indexOf('{');
      final int end = trimmed.lastIndexOf('}');
      if (start >= 0 && end > start) {
        return jsonDecode(trimmed.substring(start, end + 1));
      }
      rethrow;
    }
  }
}
