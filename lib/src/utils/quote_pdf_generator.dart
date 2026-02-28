import 'dart:io';

import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

import '../models/quote_item.dart';

class QuotePdfGenerator {
  static Future<Uint8List> generate(QuoteItem quote) async {
    final pdf = pw.Document();

    // Load Chinese TrueType font (TTF) for CJK character support
    final fontData = await rootBundle.load('assets/fonts/SourceHanSansSC.ttf');
    final font = pw.Font.ttf(fontData);
    final boldFont = pw.Font.ttf(fontData);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return [
            // Header
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(20),
              decoration: pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(width: 2, color: PdfColors.grey300),
                ),
              ),
              child: pw.Center(
                child: pw.Text(
                  '文学摘录',
                  style: pw.TextStyle(
                    font: boldFont,
                    fontSize: 28,
                    color: PdfColors.black,
                  ),
                ),
              ),
            ),

            pw.SizedBox(height: 30),

            // Beautiful words section
            if (quote.beautifulWords.isNotEmpty) ...[
              pw.Text(
                '【优美词语】',
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 20,
                  color: PdfColors.grey800,
                ),
              ),
              pw.SizedBox(height: 12),
              ...quote.beautifulWords.asMap().entries.map((entry) {
                final index = entry.key + 1;
                final word = entry.value;
                return pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 16),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        '$index. ${word.word}',
                        style: pw.TextStyle(
                          font: boldFont,
                          fontSize: 16,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        '   释义：${word.definition}',
                        style: pw.TextStyle(
                          font: font,
                          fontSize: 14,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        '   用法：${word.usage}',
                        style: pw.TextStyle(
                          font: font,
                          fontSize: 14,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              pw.SizedBox(height: 20),
            ],

            // Beautiful sentences section
            if (quote.beautifulSentences.isNotEmpty) ...[
              pw.Text(
                '【优美语句】',
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 20,
                  color: PdfColors.grey800,
                ),
              ),
              pw.SizedBox(height: 12),
              ...quote.beautifulSentences.asMap().entries.map((entry) {
                final index = entry.key + 1;
                final sentence = entry.value;
                return pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 16),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        '$index. "${sentence.sentence}"',
                        style: pw.TextStyle(
                          font: boldFont,
                          fontSize: 15,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        '   妙处：${sentence.whyGood}',
                        style: pw.TextStyle(
                          font: font,
                          fontSize: 14,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              pw.SizedBox(height: 20),
            ],

            // Reflection section
            if (quote.reflection.trim().isNotEmpty) ...[
              pw.Text(
                '【读后感】',
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 20,
                  color: PdfColors.grey800,
                ),
              ),
              pw.SizedBox(height: 12),
              pw.Text(
                quote.reflection.trim(),
                style: pw.TextStyle(
                  font: font,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              pw.SizedBox(height: 20),
            ],

            // Footer
            pw.Divider(color: PdfColors.grey300),
            pw.SizedBox(height: 8),
            pw.Text(
              _formatDate(quote.createdAt),
              style: pw.TextStyle(
                font: font,
                fontSize: 12,
                color: PdfColors.grey600,
              ),
            ),
            pw.Text(
              '来自「好词好句」',
              style: pw.TextStyle(
                font: font,
                fontSize: 12,
                color: PdfColors.grey600,
              ),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static Future<File> generateAndSave(QuoteItem quote) async {
    final pdfBytes = await generate(quote);

    final directory = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filePath = '${directory.path}/quote_$timestamp.pdf';
    final file = File(filePath);
    await file.writeAsBytes(pdfBytes);

    return file;
  }

  static String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日 ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
