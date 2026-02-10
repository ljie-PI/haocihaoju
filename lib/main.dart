import 'package:flutter/material.dart';

import 'src/app/app.dart';
import 'src/app/app_dependencies.dart';
import 'src/data/local_quote_data_source.dart';
import 'src/data/local_quote_repository.dart';
import 'src/services/llm_literature_analyzer.dart';
import 'src/services/mlkit_ocr_service.dart';
import 'src/services/mock_llm_client.dart';

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
  return AppDependencies(
    quoteRepository: LocalQuoteRepository(
      localDataSource: LocalQuoteDataSource(),
    ),
    ocrService: MlKitOcrService(),
    literatureAnalyzer: LlmLiteratureAnalyzer(
      client: MockLlmClient(),
    ),
  );
}
