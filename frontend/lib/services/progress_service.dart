import 'api_service.dart';

class ProgressService {
  // Get full stats
  static Future<Map<String, dynamic>> getProgress() async {
    return ApiService.get('/progress');
  }

  // Get words due for SM-2 review
  static Future<Map<String, dynamic>> getReviewWords() async {
    return ApiService.get('/progress/review-words');
  }

  // Save review session results
  static Future<Map<String, dynamic>> saveReview(
    List<Map<String, dynamic>> wordScores,
  ) async {
    return ApiService.post('/progress/save-review', {
      'wordScores': wordScores,
    });
  }
}