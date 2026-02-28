import 'dart:ui';

import 'package:share_plus/share_plus.dart';

import '../models/quote_item.dart';
import '../utils/quote_pdf_generator.dart';

class QuoteShareService {
  Future<void> shareQuoteAsPdf(
    QuoteItem quote, {
    required Rect sharePositionOrigin,
  }) async {
    final file = await QuotePdfGenerator.generateAndSave(quote);

    await Share.shareXFiles(
      [XFile(file.path, name: '文学摘录.pdf')],
      subject: '文学摘录分享',
      sharePositionOrigin: sharePositionOrigin,
    );
  }
}
