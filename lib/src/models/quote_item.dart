class QuoteItem {
  const QuoteItem({
    required this.id,
    required this.quote,
    required this.analysis,
    required this.styleNotes,
    required this.articleText,
    required this.createdAt,
  });

  final String id;
  final String quote;
  final String analysis;
  final String styleNotes;
  final String articleText;
  final DateTime createdAt;

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'quote': quote,
      'analysis': analysis,
      'style_notes': styleNotes,
      'article_text': articleText,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory QuoteItem.fromMap(Map<String, Object?> map) {
    return QuoteItem(
      id: map['id']! as String,
      quote: map['quote']! as String,
      analysis: map['analysis']! as String,
      styleNotes: map['style_notes']! as String,
      articleText: map['article_text']! as String,
      createdAt: DateTime.parse(map['created_at']! as String),
    );
  }
}
