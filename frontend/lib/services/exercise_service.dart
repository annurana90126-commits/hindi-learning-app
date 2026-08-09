import 'dart:math';
import '../models/word_model.dart';
import '../models/exercise_model.dart';

class ExerciseService {
  static final Random _random = Random();

  // Generate a full exercise list from a word list
  static List<ExerciseModel> generateExercises(List<WordModel> words) {
    final exercises = <ExerciseModel>[];

    for (int i = 0; i < words.length; i++) {
      final word = words[i];
      final type = _pickType(i);

      exercises.add(_buildExercise(word, words, type, i));
    }

    exercises.shuffle(_random);
    return exercises;
  }

  static ExerciseType _pickType(int index) {
    // Alternate between exercise types
    switch (index % 3) {
      case 0:
        return ExerciseType.multipleChoice;
      case 1:
        return ExerciseType.translate;
      default:
        return ExerciseType.fillBlank;
    }
  }

  static ExerciseModel _buildExercise(
    WordModel word,
    List<WordModel> allWords,
    ExerciseType type,
    int index,
  ) {
    switch (type) {
      case ExerciseType.multipleChoice:
        // Show Hindi → pick English
        final options = _getWrongOptions(word, allWords, useEnglish: true);
        options.add(word.english);
        options.shuffle(_random);
        return ExerciseModel(
          id: 'ex_$index',
          type: type,
          word: word,
          question: 'What does this mean?',
          options: options,
          correctAnswer: word.english,
        );

      case ExerciseType.translate:
        // Show English → pick Hindi
        final options = _getWrongOptions(word, allWords, useEnglish: false);
        options.add(word.hindi);
        options.shuffle(_random);
        return ExerciseModel(
          id: 'ex_$index',
          type: type,
          word: word,
          question: 'How do you say this in Hindi?',
          options: options,
          correctAnswer: word.hindi,
        );

      case ExerciseType.fillBlank:
        // Fill the blank in example sentence
        final blanked = word.exampleHindi.isNotEmpty
            ? word.exampleHindi.replaceAll(word.hindi, '______')
            : '${word.hindi} = ______';
        final options = _getWrongOptions(word, allWords, useEnglish: true);
        options.add(word.english);
        options.shuffle(_random);
        return ExerciseModel(
          id: 'ex_$index',
          type: type,
          word: word,
          question: blanked,
          options: options,
          correctAnswer: word.english,
        );
    }
  }

  static List<String> _getWrongOptions(
    WordModel correct,
    List<WordModel> allWords, {
    required bool useEnglish,
  }) {
    final others = allWords.where((w) => w.id != correct.id).toList()
      ..shuffle(_random);
    return others
        .take(3)
        .map((w) => useEnglish ? w.english : w.hindi)
        .toList();
  }
}