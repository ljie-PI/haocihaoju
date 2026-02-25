import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../app/app_dependencies.dart';
import '../../models/literary_analysis_result.dart';
import '../../models/quote_item.dart';
import '../../models/scanned_page.dart';
import '../../models/sentence_analysis.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final ImagePicker _picker = ImagePicker();
  final Uuid _uuid = const Uuid();

  final List<ScannedPage> _pages = <ScannedPage>[];
  LiteraryAnalysisResult? _analysisResult;

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
      appBar: AppBar(title: const Text('扫描与解析')),
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
                    '1）拍摄页面',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      runAlignment: WrapAlignment.center,
                      spacing: 20,
                      runSpacing: 8,
                      children: <Widget>[
                        FilledButton.icon(
                          onPressed: _processingImage ? null : _scanOnePage,
                          icon: _processingImage
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.camera_alt),
                          label: const Text('扫描页面'),
                        ),
                        OutlinedButton.icon(
                          onPressed: _pages.isEmpty ? null : _clearPages,
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('清空页面'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('已扫描页数：${_pages.length}'),
                  const SizedBox(height: 8),
                  if (_pages.isNotEmpty)
                    Text(
                      _pages
                          .map(
                            (ScannedPage p) =>
                                '第${p.pageNumber}页：${p.extractedText.length}字',
                          )
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
                    '2）文字识别合并后的文章文本',
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
                      _mergedText.isEmpty ? '暂无识别文本。' : _mergedText,
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
                    '3）好词好句抽取与解析',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: (_mergedText.isEmpty || _analyzing)
                        ? null
                        : _analyze,
                    icon: _analyzing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.auto_awesome),
                    label: const Text('开始解析'),
                  ),
                  const SizedBox(height: 12),
                  if (_analysisResult == null || _analysisResult!.isEmpty)
                    Text('暂无解析结果。', style: theme.textTheme.bodySmall)
                  else ...<Widget>[
                    Text(
                      '优美词语（${_analysisResult!.beautifulWords.length}）',
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _analysisResult!.beautifulWords
                          .map((String word) => Chip(label: Text(word)))
                          .toList(),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '优美语句（${_analysisResult!.beautifulSentences.length}）',
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    ..._analysisResult!.beautifulSentences.map(
                      (SentenceAnalysis sentence) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _SentenceCard(sentence: sentence),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('读后感', style: theme.textTheme.titleSmall),
                    const SizedBox(height: 8),
                    Text(
                      _analysisResult!.reflection,
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: OutlinedButton.icon(
                        onPressed: _saveCurrentAnalysis,
                        icon: const Icon(Icons.bookmark_add_outlined),
                        label: const Text('保存本次解析'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _scanOnePage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (!mounted || image == null) {
      return;
    }

    setState(() {
      _processingImage = true;
    });

    try {
      final String extractedText = await widget.dependencies.ocrService
          .recognizeText(image.path);
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
        _analysisResult = null;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('文字识别失败：$error')));
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
      _analysisResult = null;
    });
  }

  Future<void> _analyze() async {
    setState(() {
      _analyzing = true;
      _analysisResult = null;
    });

    try {
      final LiteraryAnalysisResult result = await widget
          .dependencies
          .literatureAnalyzer
          .analyzeArticle(_mergedText);
      if (!mounted) {
        return;
      }

      setState(() {
        _analysisResult = result;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('解析失败：$error')));
    } finally {
      if (mounted) {
        setState(() {
          _analyzing = false;
        });
      }
    }
  }

  Future<void> _saveCurrentAnalysis() async {
    final LiteraryAnalysisResult? analysis = _analysisResult;
    if (analysis == null || analysis.isEmpty) {
      return;
    }

    final QuoteItem item = QuoteItem(
      id: _uuid.v4(),
      articleText: _mergedText,
      beautifulWords: analysis.beautifulWords,
      beautifulSentences: analysis.beautifulSentences,
      reflection: analysis.reflection,
      createdAt: DateTime.now(),
    );

    try {
      await widget.dependencies.quoteRepository.addQuote(item);
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('已保存本次解析。')));
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('保存失败：$error')));
    }
  }
}

class _SentenceCard extends StatelessWidget {
  const _SentenceCard({required this.sentence});

  final SentenceAnalysis sentence;

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
          Text(sentence.sentence, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Text(sentence.whyGood, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
