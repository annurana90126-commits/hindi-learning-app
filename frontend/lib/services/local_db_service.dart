import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/lesson_model.dart';
import '../models/word_model.dart';

class LocalDbService {
  static Database? _db;

  // ─── INIT ──────────────────────────────────────────────────────────────────
  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'hindi_seekho.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Lessons table
        await db.execute('''
          CREATE TABLE lessons (
            id TEXT PRIMARY KEY,
            title TEXT,
            titleHindi TEXT,
            description TEXT,
            unitNumber INTEGER,
            lessonNumber INTEGER,
            status TEXT,
            xpReward INTEGER,
            accuracy REAL
          )
        ''');

        // Words table
        await db.execute('''
          CREATE TABLE words (
            id TEXT PRIMARY KEY,
            lessonId TEXT,
            hindi TEXT,
            english TEXT,
            transliteration TEXT,
            exampleHindi TEXT,
            exampleEnglish TEXT,
            difficulty TEXT
          )
        ''');

        // User cache table
        await db.execute('''
          CREATE TABLE user_cache (
            key TEXT PRIMARY KEY,
            value TEXT,
            updatedAt TEXT
          )
        ''');
      },
    );
  }

  // ─── LESSONS ───────────────────────────────────────────────────────────────
  static Future<void> cacheLessons(List<LessonModel> lessons) async {
    final db = await database;
    final batch = db.batch();
    for (final lesson in lessons) {
      batch.insert(
        'lessons',
        {
          'id': lesson.id,
          'title': lesson.title,
          'titleHindi': lesson.titleHindi,
          'description': lesson.description,
          'unitNumber': lesson.unitNumber,
          'lessonNumber': lesson.lessonNumber,
          'status': lesson.status.name,
          'xpReward': lesson.xpReward,
          'accuracy': lesson.accuracy,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  static Future<List<LessonModel>> getCachedLessons() async {
    final db = await database;
    final rows = await db.query('lessons', orderBy: 'unitNumber, lessonNumber');
    return rows.map((r) {
      LessonStatus status;
      switch (r['status']) {
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
        id: r['id'] as String,
        title: r['title'] as String,
        titleHindi: r['titleHindi'] as String,
        description: r['description'] as String,
        unitNumber: r['unitNumber'] as int,
        lessonNumber: r['lessonNumber'] as int,
        status: status,
        xpReward: r['xpReward'] as int,
        accuracy: r['accuracy'] as double,
      );
    }).toList();
  }

  // ─── WORDS ─────────────────────────────────────────────────────────────────
  static Future<void> cacheWords(
      String lessonId, List<WordModel> words) async {
    final db = await database;
    final batch = db.batch();
    for (final word in words) {
      batch.insert(
        'words',
        {
          'id': word.id,
          'lessonId': lessonId,
          'hindi': word.hindi,
          'english': word.english,
          'transliteration': word.transliteration,
          'exampleHindi': word.exampleHindi,
          'exampleEnglish': word.exampleEnglish,
          'difficulty': word.difficulty.name,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  static Future<List<WordModel>> getCachedWords(String lessonId) async {
    final db = await database;
    final rows = await db.query(
      'words',
      where: 'lessonId = ?',
      whereArgs: [lessonId],
    );
    return rows.map((r) {
      WordDifficulty diff;
      switch (r['difficulty']) {
        case 'medium':
          diff = WordDifficulty.medium;
          break;
        case 'hard':
          diff = WordDifficulty.hard;
          break;
        default:
          diff = WordDifficulty.easy;
      }
      return WordModel(
        id: r['id'] as String,
        hindi: r['hindi'] as String,
        english: r['english'] as String,
        transliteration: r['transliteration'] as String,
        exampleHindi: r['exampleHindi'] as String? ?? '',
        exampleEnglish: r['exampleEnglish'] as String? ?? '',
        difficulty: diff,
      );
    }).toList();
  }

  // ─── CHECK IF CACHE EXISTS ─────────────────────────────────────────────────
  static Future<bool> hasLessonsCache() async {
    final db = await database;
    final count =
        Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM lessons'));
    return (count ?? 0) > 0;
  }

  static Future<bool> hasWordsCache(String lessonId) async {
    final db = await database;
    final count = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM words WHERE lessonId = ?',
      [lessonId],
    ));
    return (count ?? 0) > 0;
  }

  // ─── CLEAR CACHE ───────────────────────────────────────────────────────────
  static Future<void> clearAll() async {
    final db = await database;
    await db.delete('lessons');
    await db.delete('words');
    await db.delete('user_cache');
  }
}