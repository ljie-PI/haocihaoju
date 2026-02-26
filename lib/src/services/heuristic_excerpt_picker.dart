import '../models/literary_analysis_result.dart';
import '../models/sentence_analysis.dart';
import '../models/word_analysis.dart';

LiteraryAnalysisResult pickHeuristicAnalysis(String articleText) {
  final List<String> sentences = articleText
      .replaceAll('\n', ' ')
      .split(RegExp(r'(?<=[。！？.!?;；])'))
      .map((String sentence) => sentence.trim())
      .where((String sentence) => sentence.length >= 12)
      .toList();

  if (sentences.isEmpty) {
    return const LiteraryAnalysisResult(
      beautifulWords: <WordAnalysis>[],
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

  final List<WordAnalysis> beautifulWords = <WordAnalysis>[
    WordAnalysis(word: '清冽', definition: '形容水质清澈寒凉', usage: '文中用"清冽"营造纯净、宁静的氛围'),
    WordAnalysis(word: '氤氲', definition: '形容烟气、水气弥漫的样子', usage: '增强画面的朦胧美感和意境深度'),
    WordAnalysis(word: '澄澈', definition: '清澈透明', usage: '突出景物或内心的清明状态'),
    WordAnalysis(word: '绵密', definition: '形容质地细密、情感深厚', usage: '强化情感或描写的细致程度'),
    WordAnalysis(word: '沉潜', definition: '沉下心、潜入深处', usage: '表现人物内心的静默与深度'),
    WordAnalysis(word: '斑驳', definition: '色彩杂乱、光影交错', usage: '增强画面层次感和时光感'),
    WordAnalysis(word: '温润', definition: '温和润泽', usage: '营造柔和、舒适的氛围'),
    WordAnalysis(word: '悠长', definition: '漫长、深远', usage: '延伸时间或情感的深度'),
    WordAnalysis(word: '微茫', definition: '微弱、隐约', usage: '表现含蓄、朦胧的美感'),
    WordAnalysis(word: '余韵', definition: '留下的韵味', usage: '突出作品的艺术感染力和回味'),
    WordAnalysis(word: '舒展', definition: '伸展、展开', usage: '表现放松、开阔的状态'),
    WordAnalysis(word: '静谧', definition: '安静、宁静', usage: '营造平和、安详的氛围'),
  ];

  return LiteraryAnalysisResult(
    beautifulWords: beautifulWords,
    beautifulSentences: selected,
    reflection:
        '这篇文字通过细节与情绪的交织，让日常经验获得了更深的意味。作者并不急于给结论，而是让场景、动作和内心变化逐步展开，形成一种缓慢却有力的推进。阅读过程中，能感受到语言在克制与抒情之间的平衡：既有具体可感的画面，也有指向人心的余味。尤其是在关键段落里，前后照应做得很自然，使主题从个体经验延伸到更普遍的生命感受。整篇文章给人的启发是，真正打动人的表达并非华丽堆砌，而是把真实情感放进准确的词句，让读者在文本中看见自己。',
  );
}
