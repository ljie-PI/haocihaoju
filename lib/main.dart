import 'package:flutter/material.dart';

import 'src/app/app.dart';
import 'src/app/app_dependencies.dart';
import 'src/data/local_quote_data_source.dart';
import 'src/data/local_quote_repository.dart';
import 'src/services/llm_literature_analyzer.dart';
import 'src/services/mlkit_ocr_service.dart';
import 'src/services/openai_compatible_chat_client.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(buildApp());
}

Widget buildApp({AppDependencies? dependencies}) {
  return HaociHaojuApp(dependencies: dependencies ?? _defaultDependencies());
}

AppDependencies _defaultDependencies() {
  const String llmBaseUrl = String.fromEnvironment('LLM_BASE_URL');
  const String llmApiKey = String.fromEnvironment('LLM_API_KEY');
  const String llmModel = String.fromEnvironment(
    'LLM_MODEL',
    defaultValue: 'gpt-4o-mini',
  );
  const String llmPath = String.fromEnvironment(
    'LLM_CHAT_COMPLETIONS_PATH',
    defaultValue: '/chat/completions',
  );

  return AppDependencies(
    quoteRepository: LocalQuoteRepository(
      localDataSource: LocalQuoteDataSource(),
    ),
    ocrService: MlKitOcrService(),
    literatureAnalyzer: LlmLiteratureAnalyzer(
      client: OpenAiCompatibleChatClient(
        baseUrl: llmBaseUrl,
        apiKey: llmApiKey,
        model: llmModel,
        chatCompletionsPath: llmPath,
      ),
    ),
  );
}
