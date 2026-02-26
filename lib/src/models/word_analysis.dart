class WordAnalysis {
  const WordAnalysis({
    required this.word,
    required this.definition,
    required this.usage,
  });

  final String word;
  final String definition;
  final String usage;

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'word': word,
      'definition': definition,
      'usage': usage,
    };
  }

  factory WordAnalysis.fromMap(Map<String, Object?> map) {
    return WordAnalysis(
      word: (map['word'] ?? '').toString().trim(),
      definition: (map['definition'] ?? '').toString().trim(),
      usage: (map['usage'] ?? '').toString().trim(),
    );
  }
}
