import '../models/quote_item.dart';

abstract class QuoteRepository {
  Future<void> initialize();

  Stream<List<QuoteItem>> watchQuotes();

  Future<List<QuoteItem>> getQuotes();

  Future<void> addQuote(QuoteItem item);

  Future<void> deleteQuote(String id);
}
