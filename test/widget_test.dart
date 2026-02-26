import 'package:flutter_test/flutter_test.dart';
import 'package:haocihaoju/main.dart';
import 'package:haocihaoju/src/app/app_dependencies.dart';
import 'package:haocihaoju/src/data/in_memory_quote_repository.dart';
import 'package:haocihaoju/src/models/literary_analysis_result.dart';
import 'package:haocihaoju/src/models/sentence_analysis.dart';
import 'package:haocihaoju/src/models/word_analysis.dart';
import 'package:haocihaoju/src/services/literature_analyzer.dart';
import 'package:haocihaoju/src/services/ocr_service.dart';

class _FakeOcrService implements OcrService {
  @override
  Future<void> dispose() async {}

  @override
  Future<String> recognizeText(String imagePath) async => '';
}

class _FakeLiteratureAnalyzer implements LiteratureAnalyzer {
  @override
  Future<LiteraryAnalysisResult> analyzeArticle(String articleText) async {
    return const LiteraryAnalysisResult(
      beautifulWords: <WordAnalysis>[],
      beautifulSentences: <SentenceAnalysis>[],
      reflection: '',
    );
  }
}

void main() {
  testWidgets('app shell renders with scan tab', (WidgetTester tester) async {
    final AppDependencies dependencies = AppDependencies(
      quoteRepository: InMemoryQuoteRepository(),
      ocrService: _FakeOcrService(),
      literatureAnalyzer: _FakeLiteratureAnalyzer(),
    );

    await tester.pumpWidget(buildApp(dependencies: dependencies));
    await tester.pumpAndSettle();

    expect(find.text('扫描与解析'), findsOneWidget);
    expect(find.text('扫描'), findsOneWidget);
    expect(find.text('摘录'), findsOneWidget);
  });
}
