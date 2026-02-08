import '../models/excerpt_suggestion.dart';

List<ExcerptSuggestion> pickHeuristicExcerpts(String articleText, {int maxItems = 6}) {
  final List<String> sentences = articleText
      .replaceAll('\n', ' ')
      .split(RegExp(r'(?<=[。！？.!?;；])'))
      .map((String sentence) => sentence.trim())
      .where((String sentence) => sentence.length >= 12)
      .toList();

  if (sentences.isEmpty) {
    return <ExcerptSuggestion>[];
  }

  int scoreSentence(String sentence) {
    const List<String> literaryHints = <String>[
      'like',
      'as if',
      'memory',
      'silence',
      'shadow',
      'light',
      'time',
      'heart',
      'wind',
      'moon',
      'rain',
      'dream',
      'metaphor',
      'rhythm',
      '孤',
      '月',
      '风',
      '雨',
      '梦',
      '心',
      '光',
      '影',
      '比喻',
      '排比',
    ];

    final String lower = sentence.toLowerCase();
    int score = sentence.length;
    for (final String hint in literaryHints) {
      if (lower.contains(hint)) {
        score += 8;
      }
    }
    return score;
  }

  final List<String> ranked = <String>[...sentences]
    ..sort((String a, String b) => scoreSentence(b).compareTo(scoreSentence(a)));

  return ranked.take(maxItems).map((String quote) {
    return ExcerptSuggestion(
      quote: quote,
      analysis: 'This line stands out for imagery and emotional tension. It works because it transforms abstract feeling into concrete language.',
      styleNotes: 'Narrative voice: lyrical. Expression: figurative, rhythmic cadence, and layered meaning in context.',
    );
  }).toList();
}
