import 'word_model.dart';

enum ExerciseType {
  multipleChoice,
  translate,
  fillBlank,
}

class ExerciseModel {
  final String id;
  final ExerciseType type;
  final WordModel word;
  final List<String> options;
  final String correctAnswer;
  final String question;

  ExerciseModel({
    required this.id,
    required this.type,
    required this.word,
    required this.options,
    required this.correctAnswer,
    required this.question,
  });
}