import '../models/literary_analysis_result.dart';
import '../models/sentence_analysis.dart';

LiteraryAnalysisResult pickHeuristicAnalysis(String articleText) {
  final List<String> sentences = articleText
      .replaceAll('\n', ' ')
      .split(RegExp(r'(?<=[。！？.!?;；])'))
      .map((String sentence) => sentence.trim())
      .where((String sentence) => sentence.length >= 12)
      .toList();

  if (sentences.isEmpty) {
    return const LiteraryAnalysisResult(
      beautifulWords: <String>[],
      beautifulSentences: <SentenceAnalysis>[],
      reflection: '',
    );
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

  final List<String> ranked = <String>[
    ...sentences,
  ]..sort((String a, String b) => scoreSentence(b).compareTo(scoreSentence(a)));

  final List<SentenceAnalysis> selected = ranked
      .take(5)
      .map(
        (String sentence) => SentenceAnalysis(
          sentence: sentence,
          whyGood: '这句话在意象组织和情绪推进上更集中，能与全文主题形成呼应，读起来有画面感和节奏感。',
        ),
      )
      .toList();

  final List<String> beautifulWords = <String>[
    '清冽',
    '氤氲',
    '澄澈',
    '绵密',
    '沉潜',
    '斑驳',
    '温润',
    '悠长',
    '微茫',
    '余韵',
    '舒展',
    '静谧',
  ];

  return LiteraryAnalysisResult(
    beautifulWords: beautifulWords,
    beautifulSentences: selected,
    reflection:
        '这篇文字通过细节与情绪的交织，让日常经验获得了更深的意味。作者并不急于给结论，而是让场景、动作和内心变化逐步展开，形成一种缓慢却有力的推进。阅读过程中，能感受到语言在克制与抒情之间的平衡：既有具体可感的画面，也有指向人心的余味。尤其是在关键段落里，前后照应做得很自然，使主题从个体经验延伸到更普遍的生命感受。整篇文章给人的启发是，真正打动人的表达并非华丽堆砌，而是把真实情感放进准确的词句，让读者在文本中看见自己。',
  );
}
