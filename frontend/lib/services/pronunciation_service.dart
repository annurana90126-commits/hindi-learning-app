import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PronunciationService {
  // Levenshtein distance — measures how different two strings are
  static int _levenshtein(String a, String b) {
    final m = a.length, n = b.length;
    final dp = List.generate(m + 1, (i) => List.filled(n + 1, 0));
    for (int i = 0; i <= m; i++) {
      dp[i][0] = i;
    }
    for (int j = 0; j <= n; j++) {
      dp[0][j] = j;
    }
    for (int i = 1; i <= m; i++) {
      for (int j = 1; j <= n; j++) {
        if (a[i - 1] == b[j - 1]) {
          dp[i][j] = dp[i - 1][j - 1];
        } else {
          dp[i][j] = 1 +
              [dp[i - 1][j], dp[i][j - 1], dp[i - 1][j - 1]]
                  .reduce((a, b) => a < b ? a : b);
        }
      }
    }
    return dp[m][n];
  }

  // Score pronunciation 0–100 based on similarity
  static int scorePronunciation(String expected, String transcribed) {
    if (transcribed.isEmpty) return 0;

    final a = expected.trim().toLowerCase();
    final b = transcribed.trim().toLowerCase();

    if (a == b) return 100;

    final maxLen = a.length > b.length ? a.length : b.length;
    if (maxLen == 0) return 100;

    final distance = _levenshtein(a, b);
    final score = ((1 - distance / maxLen) * 100).round();
    return score.clamp(0, 100);
  }

  // Send audio to backend which calls Whisper
  static Future<String> transcribeAudio(File audioFile) async {
    try {
      final uri = Uri.parse('http://10.0.2.2:5000/api/pronunciation/transcribe');
      final request = http.MultipartRequest('POST', uri);

      request.files.add(await http.MultipartFile.fromPath(
        'audio',
        audioFile.path,
      ));

      final response = await request.send().timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 200) {
        final body = await response.stream.bytesToString();
        final json = jsonDecode(body);
        return json['transcription'] ?? '';
      }

      return '';
    } catch (e) {
      // Return mock transcription for testing without backend
      return '';
    }
  }

  static String getFeedbackMessage(int score) {
    if (score >= 90) return 'Perfect pronunciation! 🌟';
    if (score >= 75) return 'Great job! Almost perfect! 👏';
    if (score >= 55) return 'Good effort! Keep practicing! 💪';
    if (score >= 30) return 'Getting there! Try again! 🎯';
    return 'Keep practicing, you\'ll get it! 🌱';
  }

  static String getFeedbackEmoji(int score) {
    if (score >= 90) return '🌟';
    if (score >= 75) return '👏';
    if (score >= 55) return '💪';
    if (score >= 30) return '🎯';
    return '🌱';
  }
}