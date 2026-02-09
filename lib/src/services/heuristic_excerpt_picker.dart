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
      analysis: '这句话在意象和情感张力上很突出，把抽象感受转化成了可感知的语言，因此更有感染力。',
      styleNotes: '叙述语气偏抒情，表达上有比喻感与节奏感，且在上下文中形成了层次递进。',
    );
  }).toList();
}
