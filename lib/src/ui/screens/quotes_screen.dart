import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/quote_repository.dart';
import '../../models/quote_item.dart';
import '../../models/sentence_analysis.dart';
import '../../models/word_analysis.dart';
import '../../services/quote_share_service.dart';
import '../../ui/widgets/word_detail_overlay.dart';

class QuotesScreen extends StatefulWidget {
  const QuotesScreen({super.key, required this.repository});

  final QuoteRepository repository;

  @override
  State<QuotesScreen> createState() => _QuotesScreenState();
}

class _QuotesScreenState extends State<QuotesScreen> {
  StreamSubscription<List<QuoteItem>>? _subscription;
  List<QuoteItem> _quotes = <QuoteItem>[];
  bool _loading = true;
  final QuoteShareService _shareService = QuoteShareService();

  @override
  void initState() {
    super.initState();
    _loadInitial();
    _subscription = widget.repository.watchQuotes().listen((
      List<QuoteItem> quotes,
    ) {
      if (!mounted) {
        return;
      }
      setState(() {
        _quotes = quotes;
      });
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('已保存解析')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _quotes.isEmpty
          ? const Center(child: Text('暂无已保存解析。'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _quotes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (BuildContext context, int index) {
                final QuoteItem item = _quotes[index];
                return _QuoteItemCard(
                  item: item,
                  onDelete: () => _delete(item.id),
                  onShare: () => _share(item),
                );
              },
            ),
    );
  }

  Future<void> _loadInitial() async {
    final List<QuoteItem> quotes = await widget.repository.getQuotes();
    if (!mounted) {
      return;
    }
    setState(() {
      _quotes = quotes;
      _loading = false;
    });
  }

  Future<void> _share(QuoteItem quote) async {
    try {
      final Rect sharePositionOrigin = _buildSharePositionOrigin(context);
      await _shareService.shareQuoteAsPdf(
        quote,
        sharePositionOrigin: sharePositionOrigin,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('分享失败：$e')),
      );
    }
  }

  Rect _buildSharePositionOrigin(BuildContext context) {
    final RenderObject? renderObject = context.findRenderObject();
    if (renderObject is RenderBox &&
        renderObject.hasSize &&
        renderObject.size.width > 0 &&
        renderObject.size.height > 0) {
      return renderObject.localToGlobal(Offset.zero) & renderObject.size;
    }

    final Size fallbackSize = MediaQuery.sizeOf(context);
    return Rect.fromLTWH(0, 0, fallbackSize.width, fallbackSize.height);
  }

  Future<void> _delete(String id) async {
    await widget.repository.deleteQuote(id);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('摘录已删除。')));
  }
}

class _QuoteItemCard extends StatelessWidget {
  const _QuoteItemCard({
    required this.item,
    required this.onDelete,
    required this.onShare,
  });

  final QuoteItem item;
  final VoidCallback onDelete;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<SentenceAnalysis> sentenceAnalyses = item.beautifulSentences;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '优美词语（${item.beautifulWords.length}）',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            if (item.beautifulWords.isEmpty)
              Text('无', style: theme.textTheme.bodySmall)
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: item.beautifulWords
                    .map((WordAnalysis word) => _WordChip(wordAnalysis: word))
                    .toList(),
              ),
            const SizedBox(height: 12),
            Text(
              '优美语句（${sentenceAnalyses.length}）',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            if (sentenceAnalyses.isEmpty)
              Text('无', style: theme.textTheme.bodySmall)
            else
              ...sentenceAnalyses.map(
                (SentenceAnalysis sentence) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        sentence.sentence,
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(sentence.whyGood, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 6),
            Text('读后感', style: theme.textTheme.titleSmall),
            const SizedBox(height: 6),
            Text(item.reflection, style: theme.textTheme.bodySmall),
            const SizedBox(height: 8),
            Text(
              item.createdAt.toIso8601String(),
              style: theme.textTheme.labelSmall,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: onShare,
                    icon: const Icon(Icons.picture_as_pdf),
                    tooltip: '分享 PDF',
                  ),
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline),
                    tooltip: '删除',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WordChip extends StatelessWidget {
  const _WordChip({
    required this.wordAnalysis,
  });

  final WordAnalysis wordAnalysis;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        WordDetailOverlay.show(
          context: context,
          detail: wordAnalysis,
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Chip(
        label: Text(wordAnalysis.word),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
