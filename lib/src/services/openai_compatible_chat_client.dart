import 'dart:convert';

import 'package:http/http.dart' as http;

import 'llm_client.dart';

class OpenAiCompatibleChatClient implements LlmClient {
  OpenAiCompatibleChatClient({
    required String baseUrl,
    required String apiKey,
    String model = 'gpt-4o-mini',
    String chatCompletionsPath = '/chat/completions',
    double temperature = 0.4,
    http.Client? client,
  }) : _baseUrl = baseUrl.trim(),
       _apiKey = apiKey.trim(),
       _model = model.trim().isEmpty ? 'gpt-4o-mini' : model.trim(),
       _chatCompletionsPath = chatCompletionsPath.trim().isEmpty
           ? '/chat/completions'
           : chatCompletionsPath.trim(),
       _temperature = temperature,
       _client = client ?? http.Client();

  final String _baseUrl;
  final String _apiKey;
  final String _model;
  final String _chatCompletionsPath;
  final double _temperature;
  final http.Client _client;

  @override
  Future<String> complete(String prompt) async {
    if (_baseUrl.isEmpty) {
      throw StateError('未配置 LLM_BASE_URL。');
    }
    if (_apiKey.isEmpty) {
      throw StateError('未配置 LLM_API_KEY。');
    }

    final Uri uri = _buildUri();
    final Map<String, Object?> payload = <String, Object?>{
      'model': _model,
      'temperature': _temperature,
      'messages': <Map<String, String>>[
        <String, String>{'role': 'user', 'content': prompt},
      ],
    };

    final http.Response response = await _client.post(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError(
        'LLM 请求失败（${response.statusCode}）：${_truncate(response.body)}',
      );
    }

    final Object? decoded = jsonDecode(response.body);
    if (decoded is! Map<String, Object?>) {
      throw const FormatException('LLM 返回体格式错误');
    }

    final String content = _extractMessageContent(decoded);
    if (content.trim().isEmpty) {
      throw const FormatException('LLM 未返回 message.content');
    }
    return content.trim();
  }

  Uri _buildUri() {
    final Uri base = Uri.parse(_baseUrl);
    if (_chatCompletionsPath.startsWith('http://') ||
        _chatCompletionsPath.startsWith('https://')) {
      return Uri.parse(_chatCompletionsPath);
    }
    final String basePath = base.path.endsWith('/')
        ? base.path.substring(0, base.path.length - 1)
        : base.path;
    final String suffix = _chatCompletionsPath.startsWith('/')
        ? _chatCompletionsPath
        : '/$_chatCompletionsPath';
    return base.replace(path: '$basePath$suffix');
  }

  String _extractMessageContent(Map<String, Object?> decoded) {
    final Object? choices = decoded['choices'];
    if (choices is! List<Object?> || choices.isEmpty) {
      return '';
    }

    final Object? firstChoice = choices.first;
    if (firstChoice is! Map<String, Object?>) {
      return '';
    }

    final Object? message = firstChoice['message'];
    if (message is! Map<String, Object?>) {
      return '';
    }

    final Object? content = message['content'];
    if (content is String) {
      return content;
    }

    if (content is List<Object?>) {
      return content
          .whereType<Map<String, Object?>>()
          .map((Map<String, Object?> part) => (part['text'] ?? '').toString())
          .join();
    }

    return '';
  }

  String _truncate(String text) {
    const int max = 280;
    return text.length <= max ? text : '${text.substring(0, max)}...';
  }

  Future<void> dispose() async {
    _client.close();
  }
}
