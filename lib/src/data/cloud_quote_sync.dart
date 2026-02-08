import '../models/quote_item.dart';

abstract class CloudQuoteSync {
  Future<void> pushQuotes(List<QuoteItem> quotes);

  Future<List<QuoteItem>> pullQuotes();
}
