import 'package:go_router/go_router.dart';

import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/lesson/screens/lesson_screen.dart';
import '../../features/lesson/screens/lesson_complete_screen.dart';
import '../../models/word_model.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      // Splash Screen
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),

      // Login Screen
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),

      // Register Screen
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Home Screen
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),

      // Lesson Screen
      GoRoute(
        path: '/lesson',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;

          return LessonScreen(
            lessonId: extra['lessonId'] as String,
            lessonTitle: extra['title'] as String,
            lessonTitleHindi: extra['titleHindi'] as String,
            xpReward: extra['xpReward'] as int,
            words: extra['words'] as List<WordModel>,
          );
        },
      ),

      // Lesson Complete Screen
      GoRoute(
        path: '/lesson-complete',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;

          return LessonCompleteScreen(
            correctAnswers: extra['correctAnswers'] as int,
            totalQuestions: extra['totalQuestions'] as int,
            xpEarned: extra['xpEarned'] as int,
          );
        },
      ),
    ],
  );
}