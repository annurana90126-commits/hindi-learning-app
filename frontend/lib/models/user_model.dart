class UserModel {
  final String id;
  final String name;
  final String email;
  final int xp;
  final int streak;
  final int level;
  final int wordsLearned;
  final int lessonsCompleted;
  final int dailyGoalXp;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.xp = 0,
    this.streak = 0,
    this.level = 1,
    this.wordsLearned = 0,
    this.lessonsCompleted = 0,
    this.dailyGoalXp = 50,
  });

  // From API response JSON
  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] ?? json['_id'] ?? '',
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        xp: json['xp'] ?? 0,
        streak: json['streak'] ?? 0,
        level: json['level'] ?? 1,
        wordsLearned: json['wordsLearned'] ?? 0,
        lessonsCompleted: json['lessonsCompleted'] ?? 0,
        dailyGoalXp: json['dailyGoalXp'] ?? 50,
      );

  // To JSON for local storage
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'xp': xp,
        'streak': streak,
        'level': level,
        'wordsLearned': wordsLearned,
        'lessonsCompleted': lessonsCompleted,
        'dailyGoalXp': dailyGoalXp,
      };

  // Dummy user for fallback/testing
  factory UserModel.dummy() => UserModel(
        id: '1',
        name: 'Anugrah',
        email: 'anugrah@example.com',
        xp: 340,
        streak: 5,
        level: 2,
        wordsLearned: 48,
        lessonsCompleted: 6,
        dailyGoalXp: 50,
      );

  int get xpForNextLevel => level * 200;
  double get xpProgress => (xp % 200) / 200;
}