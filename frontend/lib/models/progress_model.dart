class ProgressStats {
  final int xp;
  final int level;
  final int streak;
  final int wordsLearned;
  final int lessonsCompleted;
  final int dailyXp;
  final int dailyGoalXp;
  final int accuracy;
  final List<int> weeklyXp;
  final int wordsDueToday;
  final int totalWordsTracked;

  ProgressStats({
    this.xp = 0,
    this.level = 1,
    this.streak = 0,
    this.wordsLearned = 0,
    this.lessonsCompleted = 0,
    this.dailyXp = 0,
    this.dailyGoalXp = 50,
    this.accuracy = 0,
    this.weeklyXp = const [0, 0, 0, 0, 0, 0, 0],
    this.wordsDueToday = 0,
    this.totalWordsTracked = 0,
  });

  factory ProgressStats.fromJson(Map<String, dynamic> json) {
    return ProgressStats(
      xp: json['xp'] ?? 0,
      level: json['level'] ?? 1,
      streak: json['streak'] ?? 0,
      wordsLearned: json['wordsLearned'] ?? 0,
      lessonsCompleted: json['lessonsCompleted'] ?? 0,
      dailyXp: json['dailyXp'] ?? 0,
      dailyGoalXp: json['dailyGoalXp'] ?? 50,
      accuracy: json['accuracy'] ?? 0,
      weeklyXp: json['weeklyXp'] != null
          ? List<int>.from(json['weeklyXp'].map((x) => (x as num).toInt()))
          : [0, 0, 0, 0, 0, 0, 0],
      wordsDueToday: json['wordsDueToday'] ?? 0,
      totalWordsTracked: json['totalWordsTracked'] ?? 0,
    );
  }

  double get dailyGoalProgress =>
      (dailyXp / dailyGoalXp).clamp(0.0, 1.0);

  double get xpProgress => (xp % 200) / 200;

  int get xpForNextLevel => level * 200;

  int get weeklyTotalXp => weeklyXp.fold(0, (a, b) => a + b);
}