import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/quote_repository.dart';
import '../../models/quote_item.dart';

class QuotesScreen extends StatefulWidget {
  const QuotesScreen({
    super.key,
    required this.repository,
  });

  final QuoteRepository repository;

  @override
  State<QuotesScreen> createState() => _QuotesScreenState();
}

class _QuotesScreenState extends State<QuotesScreen> {
  StreamSubscription<List<QuoteItem>>? _subscription;
  List<QuoteItem> _quotes = <QuoteItem>[];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadInitial();
    _subscription = widget.repository.watchQuotes().listen((List<QuoteItem> quotes) {
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
      appBar: AppBar(title: const Text('Saved Excerpts')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _quotes.isEmpty
              ? const Center(child: Text('No saved excerpts yet.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _quotes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (BuildContext context, int index) {
                    final QuoteItem item = _quotes[index];
                    return _QuoteItemCard(
                      item: item,
                      onDelete: () => _delete(item.id),
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

  Future<void> _delete(String id) async {
    await widget.repository.deleteQuote(id);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Excerpt deleted.')),
    );
  }
}

class _QuoteItemCard extends StatelessWidget {
  const _QuoteItemCard({
    required this.item,
    required this.onDelete,
  });

  final QuoteItem item;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(item.quote, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Text(item.analysis, style: theme.textTheme.bodySmall),
            const SizedBox(height: 6),
            Text(
              item.styleNotes,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.createdAt.toIso8601String(),
              style: theme.textTheme.labelSmall,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Delete',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
