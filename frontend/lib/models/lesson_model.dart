enum LessonStatus { locked, unlocked, completed }

class LessonModel {
  final String id;
  final String title;
  final String titleHindi;
  final String description;
  final int unitNumber;
  final int lessonNumber;
  final LessonStatus status;
  final int xpReward;
  final int totalWords;
  final double accuracy;

  LessonModel({
    required this.id,
    required this.title,
    required this.titleHindi,
    required this.description,
    required this.unitNumber,
    required this.lessonNumber,
    this.status = LessonStatus.locked,
    this.xpReward = 10,
    this.totalWords = 8,
    this.accuracy = 0.0,
  });

  // From API JSON
  factory LessonModel.fromJson(Map<String, dynamic> json) {
    LessonStatus status;
    switch (json['status']) {
      case 'completed':
        status = LessonStatus.completed;
        break;
      case 'unlocked':
        status = LessonStatus.unlocked;
        break;
      default:
        status = LessonStatus.locked;
    }

    return LessonModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      title: json['title'] ?? '',
      titleHindi: json['titleHindi'] ?? '',
      description: json['description'] ?? '',
      unitNumber: json['unitNumber'] ?? 1,
      lessonNumber: json['lessonNumber'] ?? 1,
      status: status,
      xpReward: json['xpReward'] ?? 10,
      totalWords: json['totalWords'] ?? 8,
      accuracy: (json['accuracy'] ?? 0.0).toDouble(),
    );
  }

  static List<LessonModel> dummyLessons() => [
        LessonModel(
          id: '1',
          title: 'Greetings',
          titleHindi: 'अभिवादन',
          description: 'Learn basic Hindi greetings',
          unitNumber: 1,
          lessonNumber: 1,
          status: LessonStatus.completed,
          xpReward: 10,
          accuracy: 92.0,
        ),
        LessonModel(
          id: '2',
          title: 'Numbers 1–10',
          titleHindi: 'संख्याएं',
          description: 'Count from one to ten in Hindi',
          unitNumber: 1,
          lessonNumber: 2,
          status: LessonStatus.unlocked,
          xpReward: 10,
        ),
        LessonModel(
          id: '3',
          title: 'Colors',
          titleHindi: 'रंग',
          description: 'Learn the names of colors',
          unitNumber: 1,
          lessonNumber: 3,
          status: LessonStatus.locked,
          xpReward: 10,
        ),
      ];
}