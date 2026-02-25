import 'dart:async';

import '../models/quote_item.dart';
import 'cloud_quote_sync.dart';
import 'local_quote_data_source.dart';
import 'quote_repository.dart';

class LocalQuoteRepository implements QuoteRepository {
  LocalQuoteRepository({
    required LocalQuoteDataSource localDataSource,
    CloudQuoteSync? cloudSync,
  }) : _localDataSource = localDataSource,
       _cloudSync = cloudSync;

  final LocalQuoteDataSource _localDataSource;
  final CloudQuoteSync? _cloudSync;

  final StreamController<List<QuoteItem>> _controller =
      StreamController<List<QuoteItem>>.broadcast();

  bool _initialized = false;

  @override
  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    _initialized = true;
    await _emitCurrentQuotes();
  }

  @override
  Stream<List<QuoteItem>> watchQuotes() {
    return _controller.stream;
  }

  @override
  Future<List<QuoteItem>> getQuotes() {
    return _localDataSource.getQuotes();
  }

  @override
  Future<void> addQuote(QuoteItem item) async {
    await _localDataSource.addQuote(item);
    await _emitCurrentQuotes();
    await _bestEffortSync();
  }

  @override
  Future<void> deleteQuote(String id) async {
    await _localDataSource.deleteQuote(id);
    await _emitCurrentQuotes();
    await _bestEffortSync();
  }

  Future<void> _emitCurrentQuotes() async {
    final List<QuoteItem> quotes = await _localDataSource.getQuotes();
    if (!_controller.isClosed) {
      _controller.add(quotes);
    }
  }

  Future<void> _bestEffortSync() async {
    if (_cloudSync == null) {
      return;
    }

    try {
      await _cloudSync.pushQuotes(await _localDataSource.getQuotes());
    } catch (_) {
      // Keep local flow resilient even if cloud sync is unavailable.
    }
  }
}
