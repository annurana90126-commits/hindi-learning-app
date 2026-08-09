import 'package:go_router/go_router.dart';
import '../../../services/lesson_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/word_model.dart';
import '../../../models/exercise_model.dart';
import '../../../services/exercise_service.dart';
import '../widgets/lesson_progress_bar.dart';
import '../widgets/answer_option.dart';

class LessonScreen extends StatefulWidget {
  final String lessonId;
  final String lessonTitle;
  final String lessonTitleHindi;
  final int xpReward;
  final List<WordModel> words;

  const LessonScreen({
    super.key,
    required this.lessonId,
    required this.lessonTitle,
    required this.lessonTitleHindi,
    required this.xpReward,
    required this.words,
  });

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen>
    with SingleTickerProviderStateMixin {
  late List<ExerciseModel> _exercises;
  int _currentIndex = 0;
  String? _selectedAnswer;
  bool _isAnswered = false;
  int _correctCount = 0;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _exercises = ExerciseService.generateExercises(widget.words);

if (_exercises.isEmpty) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    Navigator.pop(context);
  });
}
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  ExerciseModel get _current => _exercises[_currentIndex];

  void _selectAnswer(String answer) {
    if (_isAnswered) return;

    final isCorrect = answer == _current.correctAnswer;

    if (isCorrect) {
      HapticFeedback.lightImpact();
      setState(() {
        _selectedAnswer = answer;
        _isAnswered = true;
        _correctCount++;
      });
    } else {
      HapticFeedback.heavyImpact();
      _shakeController.forward(from: 0);
      setState(() {
        _selectedAnswer = answer;
        _isAnswered = true;
      });
    }
  }

  void _nextExercise() async{
    if (_currentIndex < _exercises.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedAnswer = null;
        _isAnswered = false;
      });
    } else {
      // Lesson complete
      final accuracy = (_correctCount / _exercises.length) * 100;

    final xpEarned =
        (accuracy / 100 * widget.xpReward).round();

    await LessonService.completeLesson(
      lessonId: widget.lessonId,
      accuracy: accuracy,
      xpEarned: xpEarned,
      wordScores: [],
    );

    if (!mounted) return;

    context.go(
  '/lesson-complete',
  extra: {
    'correctAnswers': _correctCount,
    'totalQuestions': _exercises.length,
    'xpEarned': xpEarned,
  },
);
  }
}

  void _showQuitDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Quit Lesson?', style: AppTextStyles.heading3),
        content: const Text(
          'Your progress will be lost. Are you sure?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Keep Going',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.primary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: Text('Quit',
                style:
                    AppTextStyles.bodyMedium.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  OptionState _getOptionState(String option) {
    if (!_isAnswered) {
      return _selectedAnswer == option
          ? OptionState.selected
          : OptionState.idle;
    }
    if (option == _current.correctAnswer) return OptionState.correct;
    if (option == _selectedAnswer) return OptionState.wrong;
    return OptionState.idle;
  }

  @override
  Widget build(BuildContext context) {
    final exercise = _current;
    final isCorrect =
        _isAnswered && _selectedAnswer == exercise.correctAnswer;
    final isTranslate = exercise.type == ExerciseType.translate;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar
            LessonProgressBar(
              current: _currentIndex + 1,
              total: _exercises.length,
              onClose: _showQuitDialog,
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Exercise type label
                    Text(
                      exercise.type == ExerciseType.multipleChoice
                          ? 'What does this mean?'
                          : exercise.type == ExerciseType.translate
                              ? 'How do you say this in Hindi?'
                              : 'Fill in the blank',
                      style: AppTextStyles.heading3,
                    ),

                    const SizedBox(height: 24),

                    // Word card
                    AnimatedBuilder(
                      animation: _shakeAnim,
                      builder: (context, child) {
                        final offset = _shakeController.isAnimating
                            ? 8 * (0.5 - (_shakeAnim.value - 0.5).abs())
                            : 0.0;
                        return Transform.translate(
                          offset: Offset(offset * 4, 0),
                          child: child,
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Main word display
                            if (exercise.type ==
                                ExerciseType.multipleChoice) ...[
                              Text(
                                exercise.word.hindi,
                                style: AppTextStyles.hindiLarge.copyWith(
                                  color: AppColors.primary,
                                  fontSize: 48,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                exercise.word.transliteration,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontStyle: FontStyle.italic,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ] else if (exercise.type ==
                                ExerciseType.translate) ...[
                              Text(
                                exercise.word.english,
                                style: AppTextStyles.heading1.copyWith(
                                  color: AppColors.secondary,
                                  fontSize: 32,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ] else ...[
                              // Fill in blank - show example sentence
                              Text(
                                exercise.question,
                                style: AppTextStyles.hindiMedium.copyWith(
                                  color: AppColors.textPrimary,
                                  fontSize: 22,
                                  height: 1.6,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                exercise.word.exampleEnglish,
                                style: AppTextStyles.bodySmall.copyWith(
                                  fontStyle: FontStyle.italic,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Answer options
                    ...exercise.options.map((option) => AnswerOption(
                          text: option,
                          state: _getOptionState(option),
                          isHindi: isTranslate,
                          onTap: () => _selectAnswer(option),
                        )),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            // Bottom feedback + next button
            if (_isAnswered)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                decoration: BoxDecoration(
                  color: isCorrect
                      ? AppColors.success.withValues(alpha: 0.1)
                      : AppColors.error.withValues(alpha: 0.08),
                  border: Border(
                    top: BorderSide(
                      color: isCorrect
                          ? AppColors.success.withValues(alpha: 0.3)
                          : AppColors.error.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isCorrect ? Icons.check_circle : Icons.cancel,
                          color: isCorrect ? AppColors.success : AppColors.error,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isCorrect ? 'Correct! 🎉' : 'Incorrect',
                          style: AppTextStyles.heading3.copyWith(
                            color: isCorrect
                                ? AppColors.success
                                : AppColors.error,
                          ),
                        ),
                      ],
                    ),
                    if (!isCorrect) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Correct answer: ${_current.correctAnswer}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _nextExercise,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isCorrect
                              ? AppColors.success
                              : AppColors.primary,
                        ),
                        child: Text(
                          _currentIndex < _exercises.length - 1
                              ? 'Continue'
                              : 'Finish Lesson',
                          style: AppTextStyles.button,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}