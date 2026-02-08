import 'dart:async';

import '../models/quote_item.dart';
import 'quote_repository.dart';

class InMemoryQuoteRepository implements QuoteRepository {
  final List<QuoteItem> _quotes = <QuoteItem>[];
  final StreamController<List<QuoteItem>> _controller =
      StreamController<List<QuoteItem>>.broadcast();

  @override
  Future<void> initialize() async {
    _controller.add(List<QuoteItem>.unmodifiable(_quotes));
  }

  @override
  Stream<List<QuoteItem>> watchQuotes() => _controller.stream;

  @override
  Future<List<QuoteItem>> getQuotes() async => List<QuoteItem>.unmodifiable(_quotes);

  @override
  Future<void> addQuote(QuoteItem item) async {
    _quotes.removeWhere((QuoteItem quote) => quote.id == item.id);
    _quotes.insert(0, item);
    _controller.add(List<QuoteItem>.unmodifiable(_quotes));
  }

  @override
  Future<void> deleteQuote(String id) async {
    _quotes.removeWhere((QuoteItem quote) => quote.id == id);
    _controller.add(List<QuoteItem>.unmodifiable(_quotes));
  }
}
