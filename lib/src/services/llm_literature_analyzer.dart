import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/literary_analysis_result.dart';
import '../models/sentence_analysis.dart';
import 'heuristic_excerpt_picker.dart';
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
        beautifulWords: <String>[],
        beautifulSentences: <SentenceAnalysis>[],
        reflection: '',
      );
    }

    final String prompt = await _buildPrompt(articleText);
    final String rawResponse = await _client.complete(prompt);
    try {
      final LiteraryAnalysisResult result = _parseResult(rawResponse);
      if (_isValidResult(result)) {
        return result;
      }
      return pickHeuristicAnalysis(articleText);
    } catch (_) {
      return pickHeuristicAnalysis(articleText);
    }
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

    final List<String> beautifulWords = _extractWords(
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

  List<String> _extractWords(Object? rawWords) {
    if (rawWords is! List<Object?>) {
      return <String>[];
    }
    return rawWords
        .map((Object? word) => (word ?? '').toString().trim())
        .where((String word) => word.isNotEmpty)
        .toSet()
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
