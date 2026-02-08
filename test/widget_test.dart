import 'package:flutter_test/flutter_test.dart';
import 'package:haocihaoju/main.dart';
import 'package:haocihaoju/src/app/app_dependencies.dart';
import 'package:haocihaoju/src/data/in_memory_quote_repository.dart';
import 'package:haocihaoju/src/models/excerpt_suggestion.dart';
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
  Future<List<ExcerptSuggestion>> analyzeArticle(String articleText) async {
    return const <ExcerptSuggestion>[];
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

    expect(find.text('Scan and Analyze'), findsOneWidget);
    expect(find.text('Scan'), findsOneWidget);
    expect(find.text('Excerpts'), findsOneWidget);
  });
}
