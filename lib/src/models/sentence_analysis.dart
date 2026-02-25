class SentenceAnalysis {
  const SentenceAnalysis({required this.sentence, required this.whyGood});

  final String sentence;
  final String whyGood;

  Map<String, Object?> toMap() {
    return <String, Object?>{'sentence': sentence, 'why_good': whyGood};
  }

  factory SentenceAnalysis.fromMap(Map<String, Object?> map) {
    return SentenceAnalysis(
      sentence: (map['sentence'] ?? '').toString().trim(),
      whyGood: (map['why_good'] ?? '').toString().trim(),
    );
  }
}
