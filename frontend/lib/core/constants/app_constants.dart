class AppConstants {
  // API
  static const String baseUrl =
    'https://hindi-learning-app-production.up.railway.app/api';

  // Note: Railway backend is used in production

  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';

  // App info
  static const String appName = 'हिंदी सीखो';
  static const String appNameEn = 'Hindi Seekho';

  // Gamification
  static const int xpPerLesson = 10;
  static const int xpPerPronunciation = 5;
  static const int xpPerPerfectScore = 20;

  // SRS intervals (in days)
  static const List<int> srsIntervals = [1, 3, 7, 14, 30, 90];

  // Pronunciation scoring
  static const int goodScoreThreshold = 80;
  static const int averageScoreThreshold = 50;
}