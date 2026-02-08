import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../app/app_dependencies.dart';
import '../../models/excerpt_suggestion.dart';
import '../../models/quote_item.dart';
import '../../models/scanned_page.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({
    super.key,
    required this.dependencies,
  });

  final AppDependencies dependencies;

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final ImagePicker _picker = ImagePicker();
  final Uuid _uuid = const Uuid();

  final List<ScannedPage> _pages = <ScannedPage>[];
  List<ExcerptSuggestion> _suggestions = <ExcerptSuggestion>[];

  bool _processingImage = false;
  bool _analyzing = false;

  String get _mergedText {
    return _pages
        .map((ScannedPage page) => page.extractedText.trim())
        .where((String text) => text.isNotEmpty)
        .join('\n\n');
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan and Analyze'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    '1) Capture pages from camera',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      FilledButton.icon(
                        onPressed: _processingImage ? null : _scanOnePage,
                        icon: _processingImage
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.camera_alt),
                        label: const Text('Scan next page'),
                      ),
                      OutlinedButton.icon(
                        onPressed: _pages.isEmpty ? null : _clearPages,
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Clear pages'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('Pages scanned: ${_pages.length}'),
                  const SizedBox(height: 8),
                  if (_pages.isNotEmpty)
                    Text(
                      _pages
                          .map((ScannedPage p) => 'P${p.pageNumber}: ${p.extractedText.length} chars')
                          .join('  |  '),
                      style: theme.textTheme.bodySmall,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    '2) OCR merged article text',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SelectableText(
                      _mergedText.isEmpty ? 'No OCR text yet.' : _mergedText,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    '3) LLM literary extraction and commentary',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: (_mergedText.isEmpty || _analyzing) ? null : _analyze,
                    icon: _analyzing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.auto_awesome),
                    label: const Text('Analyze article'),
                  ),
                  const SizedBox(height: 12),
                  if (_suggestions.isEmpty)
                    Text(
                      'No excerpt suggestions yet.',
                      style: theme.textTheme.bodySmall,
                    )
                  else
                    ..._suggestions.map(
                      (ExcerptSuggestion suggestion) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _SuggestionCard(
                          suggestion: suggestion,
                          onSave: () => _saveSuggestion(suggestion),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _scanOnePage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 90,
    );
    if (!mounted || image == null) {
      return;
    }

    setState(() {
      _processingImage = true;
    });

    try {
      final String extractedText = await widget.dependencies.ocrService.recognizeText(image.path);
      if (!mounted) {
        return;
      }

      setState(() {
        _pages.add(
          ScannedPage(
            id: _uuid.v4(),
            pageNumber: _pages.length + 1,
            imagePath: image.path,
            extractedText: extractedText,
          ),
        );
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OCR failed: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _processingImage = false;
        });
      }
    }
  }

  void _clearPages() {
    setState(() {
      _pages.clear();
      _suggestions = <ExcerptSuggestion>[];
    });
  }

  Future<void> _analyze() async {
    setState(() {
      _analyzing = true;
      _suggestions = <ExcerptSuggestion>[];
    });

    try {
      final List<ExcerptSuggestion> result =
          await widget.dependencies.literatureAnalyzer.analyzeArticle(_mergedText);
      if (!mounted) {
        return;
      }

      setState(() {
        _suggestions = result;
      });
    } finally {
      if (mounted) {
        setState(() {
          _analyzing = false;
        });
      }
    }
  }

  Future<void> _saveSuggestion(ExcerptSuggestion suggestion) async {
    final QuoteItem item = QuoteItem(
      id: _uuid.v4(),
      quote: suggestion.quote,
      analysis: suggestion.analysis,
      styleNotes: suggestion.styleNotes,
      articleText: _mergedText,
      createdAt: DateTime.now(),
    );

    await widget.dependencies.quoteRepository.addQuote(item);
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saved to excerpts.')),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({
    required this.suggestion,
    required this.onSave,
  });

  final ExcerptSuggestion suggestion;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            suggestion.quote,
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Text(suggestion.analysis, style: theme.textTheme.bodySmall),
          const SizedBox(height: 6),
          Text(
            suggestion.styleNotes,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: onSave,
              icon: const Icon(Icons.bookmark_add_outlined),
              label: const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }
}
