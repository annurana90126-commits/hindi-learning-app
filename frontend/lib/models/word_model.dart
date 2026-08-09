enum WordDifficulty { easy, medium, hard }

class WordModel {
  final String id;
  final String hindi;
  final String english;
  final String transliteration;
  final String exampleHindi;
  final String exampleEnglish;
  final WordDifficulty difficulty;
  final String? audioUrl;

  WordModel({
    required this.id,
    required this.hindi,
    required this.english,
    required this.transliteration,
    this.exampleHindi = '',
    this.exampleEnglish = '',
    this.difficulty = WordDifficulty.easy,
    this.audioUrl,
  });

  // From API JSON
  factory WordModel.fromJson(Map<String, dynamic> json) {
    WordDifficulty diff;
    switch (json['difficulty']) {
      case 'medium':
        diff = WordDifficulty.medium;
        break;
      case 'hard':
        diff = WordDifficulty.hard;
        break;
      default:
        diff = WordDifficulty.easy;
    }

    return WordModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      hindi: json['hindi'] ?? '',
      english: json['english'] ?? '',
      transliteration: json['transliteration'] ?? '',
      exampleHindi: json['exampleHindi'] ?? '',
      exampleEnglish: json['exampleEnglish'] ?? '',
      difficulty: diff,
      audioUrl: json['audioUrl'],
    );
  }

  static List<WordModel> dummyWords() => [
        WordModel(
          id: 'w1',
          hindi: 'नमस्ते',
          english: 'Hello',
          transliteration: 'Namaste',
          exampleHindi: 'नमस्ते, आप कैसे हैं?',
          exampleEnglish: 'Hello, how are you?',
        ),
        WordModel(
          id: 'w2',
          hindi: 'धन्यवाद',
          english: 'Thank you',
          transliteration: 'Dhanyavaad',
          exampleHindi: 'धन्यवाद आपकी मदद के लिए।',
          exampleEnglish: 'Thank you for your help.',
        ),
        WordModel(
          id: 'w3',
          hindi: 'हाँ',
          english: 'Yes',
          transliteration: 'Haan',
          exampleHindi: 'हाँ, मैं ठीक हूँ।',
          exampleEnglish: 'Yes, I am fine.',
        ),
        WordModel(
          id: 'w4',
          hindi: 'नहीं',
          english: 'No',
          transliteration: 'Nahin',
          exampleHindi: 'नहीं, मुझे नहीं पता।',
          exampleEnglish: 'No, I do not know.',
        ),
        WordModel(
          id: 'w5',
          hindi: 'पानी',
          english: 'Water',
          transliteration: 'Paani',
          exampleHindi: 'मुझे पानी चाहिए।',
          exampleEnglish: 'I need water.',
        ),
        WordModel(
          id: 'w6',
          hindi: 'खाना',
          english: 'Food',
          transliteration: 'Khaana',
          exampleHindi: 'खाना बहुत अच्छा है।',
          exampleEnglish: 'The food is very good.',
        ),
      ];
}