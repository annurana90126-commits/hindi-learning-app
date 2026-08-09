import '../models/lesson_model.dart';
import '../models/word_model.dart';
import 'api_service.dart';
import 'local_db_service.dart';
import 'connectivity_service.dart';

class LessonService {
  // ─── GET ALL LESSONS (offline-first) ─────────────────────────────────────
  static Future<List<LessonModel>> getLessons() async {
    final online = await ConnectivityService.isOnline();

    if (online) {
      try {
        final data = await ApiService.get('/lessons');
        if (data['success'] == true) {
          final List lessons = data['lessons'];
          final models = lessons.map((l) => LessonModel.fromJson(l)).toList();
          // Cache for offline use
          await LocalDbService.cacheLessons(models);
          return models;
        }
      } catch (_) {}
    }

    // Offline fallback — use cached data
    final cached = await LocalDbService.getCachedLessons();
    if (cached.isNotEmpty) return cached;

    // Last resort — dummy data
    return LessonModel.dummyLessons();
  }

  // ─── GET WORDS FOR LESSON (offline-first) ────────────────────────────────
  static Future<List<WordModel>> getLessonWords(String lessonId) async {
    final online = await ConnectivityService.isOnline();

    if (online) {
      try {
        final data = await ApiService.get('/lessons/$lessonId/words');
        if (data['success'] == true) {
          final List words = data['words'];
          final models = words.map((w) => WordModel.fromJson(w)).toList();
          // Cache words locally
          await LocalDbService.cacheWords(lessonId, models);
          return models;
        }
      } catch (_) {}
    }

    // Offline fallback
    final cached = await LocalDbService.getCachedWords(lessonId);
    if (cached.isNotEmpty) return cached;

    return WordModel.dummyWords();
  }

  // ─── COMPLETE LESSON ─────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> completeLesson({
    required String lessonId,
    required double accuracy,
    required int xpEarned,
    required List<Map<String, dynamic>> wordScores,
  }) async {
    final online = await ConnectivityService.isOnline();
    if (!online) {
      return {
        'success': false,
        'message': 'You are offline. Progress will sync when online.',
      };
    }

    return ApiService.post('/lessons/complete', {
      'lessonId': lessonId,
      'accuracy': accuracy,
      'xpEarned': xpEarned,
      'wordScores': wordScores,
    });
  }
}