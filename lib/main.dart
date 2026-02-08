import 'package:flutter/material.dart';

import 'src/app/app.dart';
import 'src/app/app_dependencies.dart';
import 'src/data/local_quote_data_source.dart';
import 'src/data/local_quote_repository.dart';
import 'src/services/llm_literature_analyzer.dart';
import 'src/services/mock_llm_client.dart';
import 'src/services/remote_ocr_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(buildApp());
}

Widget buildApp({AppDependencies? dependencies}) {
  return HaociHaojuApp(
    dependencies: dependencies ?? _defaultDependencies(),
  );
}

AppDependencies _defaultDependencies() {
  const String ocrApiUrl = String.fromEnvironment('OCR_API_URL');
  const String ocrApiKey = String.fromEnvironment('OCR_API_KEY');
  const String ocrApiKeyHeader =
      String.fromEnvironment('OCR_API_KEY_HEADER', defaultValue: 'Authorization');
  const String ocrImageField =
      String.fromEnvironment('OCR_IMAGE_FIELD', defaultValue: 'image');
  const String ocrTextField =
      String.fromEnvironment('OCR_TEXT_FIELD', defaultValue: 'text');

  return AppDependencies(
    quoteRepository: LocalQuoteRepository(
      localDataSource: LocalQuoteDataSource(),
    ),
    ocrService: RemoteOcrService(
      endpoint: ocrApiUrl,
      apiKey: ocrApiKey,
      apiKeyHeader: ocrApiKeyHeader,
      imageFieldName: ocrImageField,
      textFieldPath: ocrTextField,
    ),
    literatureAnalyzer: LlmLiteratureAnalyzer(
      client: MockLlmClient(),
    ),
  );
}
