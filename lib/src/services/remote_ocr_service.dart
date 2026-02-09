import 'dart:convert';

import 'package:http/http.dart' as http;

import 'ocr_service.dart';

class RemoteOcrService implements OcrService {
  RemoteOcrService({
    required String endpoint,
    String apiKey = '',
    String apiKeyHeader = 'Authorization',
    String imageFieldName = 'image',
    String textFieldPath = '',
    http.Client? client,
  })  : _endpoint = endpoint.trim(),
        _apiKey = apiKey.trim(),
        _apiKeyHeader = apiKeyHeader.trim().isEmpty ? 'Authorization' : apiKeyHeader.trim(),
        _imageFieldName = imageFieldName.trim().isEmpty ? 'image' : imageFieldName.trim(),
        _textFieldPath = textFieldPath.trim(),
        _client = client ?? http.Client();

  final String _endpoint;
  final String _apiKey;
  final String _apiKeyHeader;
  final String _imageFieldName;
  final String _textFieldPath;
  final http.Client _client;

  @override
  Future<String> recognizeText(String imagePath) async {
    if (_endpoint.isEmpty) {
      throw StateError('未配置远程文字识别服务地址（OCR_API_URL）。');
    }

    final Uri uri = Uri.parse(_endpoint);
    final http.MultipartRequest request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath(_imageFieldName, imagePath));

    if (_apiKey.isNotEmpty) {
      request.headers[_apiKeyHeader] =
          _apiKeyHeader.toLowerCase() == 'authorization' ? 'Bearer $_apiKey' : _apiKey;
    }

    final http.StreamedResponse streamedResponse = await _client.send(request);
    final http.Response response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('远程文字识别请求失败（${response.statusCode}）：${_truncate(response.body)}');
    }

    final String text = _extractText(response);
    if (text.trim().isEmpty) {
      throw StateError('远程文字识别返回中未找到识别文本。');
    }
    return text.trim();
  }

  String _extractText(http.Response response) {
    final String rawBody = response.body;

    dynamic decoded;
    try {
      decoded = jsonDecode(rawBody);
    } catch (_) {
      return rawBody.trim();
    }

    final String fromConfiguredField = _extractFromConfiguredField(decoded);
    if (fromConfiguredField.isNotEmpty) {
      return fromConfiguredField;
    }

    final String fromCommonFields = _extractFromCommonFields(decoded);
    if (fromCommonFields.isNotEmpty) {
      return fromCommonFields;
    }

    if (decoded is String) {
      return decoded.trim();
    }
    return rawBody.trim();
  }

  String _extractFromConfiguredField(dynamic decoded) {
    if (_textFieldPath.isEmpty) {
      return '';
    }

    dynamic current = decoded;
    for (final String segment in _textFieldPath.split('.')) {
      if (current is Map<String, dynamic> && current.containsKey(segment)) {
        current = current[segment];
      } else {
        return '';
      }
    }

    return current is String ? current.trim() : '';
  }

  String _extractFromCommonFields(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      const List<String> keys = <String>['text', 'ocr_text', 'content', 'resultText', 'output_text'];
      for (final String key in keys) {
        final dynamic value = decoded[key];
        if (value is String && value.trim().isNotEmpty) {
          return value.trim();
        }
      }

      final dynamic data = decoded['data'];
      if (data is Map<String, dynamic>) {
        final dynamic dataText = data['text'];
        if (dataText is String && dataText.trim().isNotEmpty) {
          return dataText.trim();
        }
      }

      final dynamic result = decoded['result'];
      if (result is Map<String, dynamic>) {
        final dynamic resultText = result['text'];
        if (resultText is String && resultText.trim().isNotEmpty) {
          return resultText.trim();
        }
      }

      final dynamic choices = decoded['choices'];
      if (choices is List && choices.isNotEmpty) {
        final dynamic first = choices.first;
        if (first is Map<String, dynamic>) {
          final dynamic message = first['message'];
          if (message is Map<String, dynamic>) {
            final dynamic content = message['content'];
            if (content is String && content.trim().isNotEmpty) {
              return content.trim();
            }
          }
        }
      }
    }

    return '';
  }

  String _truncate(String text) {
    const int max = 280;
    return text.length <= max ? text : '${text.substring(0, max)}...';
  }

  @override
  Future<void> dispose() async {
    _client.close();
  }
}
