const Lesson = require('../models/Lesson');
const Word = require('../models/Word');
const UserProgress = require('../models/UserProgress');

// ─── GET ALL LESSONS WITH USER PROGRESS ──────────────────────────────────────
const getLessons = async (req, res, next) => {
  try {
    const lessons = await Lesson.find({ isActive: true }).sort({ order: 1 });

    // Get user progress
    const progress = await UserProgress.findOne({
      userId: req.user._id,
    });

    const lessonsWithStatus = lessons.map((lesson, index) => {
      const lessonProgress = progress?.lessons.find(
        (lp) => lp.lessonId.toString() === lesson._id.toString()
      );

      // First lesson is always unlocked
      // Other lessons unlock sequentially
      let status = 'locked';

      if (lessonProgress?.completed) {
        status = 'completed';
      } else if (index === 0) {
        status = 'unlocked';
      } else {
        const previousLesson = lessons[index - 1];

        const previousProgress = progress?.lessons.find(
          (lp) =>
            lp.lessonId.toString() === previousLesson._id.toString()
        );

        if (previousProgress?.completed) {
          status = 'unlocked';
        }
      }

      return {
        id: lesson._id,
        title: lesson.title,
        titleHindi: lesson.titleHindi,
        description: lesson.description,
        unitNumber: lesson.unitNumber,
        lessonNumber: lesson.lessonNumber,
        xpReward: lesson.xpReward,
        status,
        accuracy: lessonProgress?.accuracy || 0,
      };
    });

    res.status(200).json({
      success: true,
      lessons: lessonsWithStatus,
    });
  } catch (error) {
    next(error);
  }
};

// ─── GET WORDS FOR A LESSON ───────────────────────────────────────────────────
const getLessonWords = async (req, res, next) => {
  try {
    const { lessonId } = req.params;

    const lesson = await Lesson.findById(lessonId);

    if (!lesson) {
      return res.status(404).json({
        success: false,
        message: 'Lesson not found',
      });
    }

    const words = await Word.find({ lessonId });

    res.status(200).json({
      success: true,
      lesson: {
        id: lesson._id,
        title: lesson.title,
        titleHindi: lesson.titleHindi,
        xpReward: lesson.xpReward,
      },

      words: words.map((w) => ({
        id: w._id,
        hindi: w.hindi,
        english: w.english,
        transliteration: w.transliteration,
        exampleHindi: w.exampleHindi,
        exampleEnglish: w.exampleEnglish,
        difficulty: w.difficulty,
        audioUrl: w.audioUrl,
      })),
    });
  } catch (error) {
    next(error);
  }
};

// ─── COMPLETE LESSON ──────────────────────────────────────────────────────────
const completeLesson = async (req, res, next) => {
  try {
    const {
      lessonId,
      accuracy,
      xpEarned,
      wordScores,
    } = req.body;

    // Validate request
    if (!lessonId || accuracy === undefined) {
      return res.status(400).json({
        success: false,
        message: 'lessonId and accuracy are required',
      });
    }

    // Find lesson
    const lesson = await Lesson.findById(lessonId);

    if (!lesson) {
      return res.status(404).json({
        success: false,
        message: 'Lesson not found',
      });
    }

    // ─── GET OR CREATE USER PROGRESS ────────────────────────────────────────
    let progress = await UserProgress.findOne({
      userId: req.user._id,
    });

    if (!progress) {
      progress = new UserProgress({
        userId: req.user._id,
      });
    }

    // ─── UPDATE LESSON PROGRESS ─────────────────────────────────────────────
    const existingLesson = progress.lessons.find(
      (lp) => lp.lessonId.toString() === lessonId
    );

    if (existingLesson) {
      // Keep the better accuracy
      if (accuracy > existingLesson.accuracy) {
        existingLesson.accuracy = accuracy;
        existingLesson.xpEarned =
          xpEarned || lesson.xpReward;
      }

      existingLesson.completed = true;
      existingLesson.completedAt = new Date();
    } else {
      progress.lessons.push({
        lessonId,
        completed: true,
        accuracy,
        xpEarned: xpEarned || lesson.xpReward,
        completedAt: new Date(),
      });
    }

    // ─── UPDATE WORD PROGRESS ───────────────────────────────────────────────
    if (Array.isArray(wordScores) && wordScores.length > 0) {
      for (const ws of wordScores) {
        // Ignore invalid word scores
        if (!ws.wordId) {
          continue;
        }

        const existingWord = progress.words.find(
          (wp) => wp.wordId.toString() === ws.wordId
        );

        if (existingWord) {
          existingWord.attempts += 1;

          if (ws.correct) {
            existingWord.correct += 1;
          }

          existingWord.score = Math.round(
            (existingWord.correct / existingWord.attempts) * 100
          );

          // SM-2 update
          const {
            interval,
            easeFactor,
          } = sm2Update(
            existingWord.interval,
            existingWord.easeFactor,
            Number(ws.score) || 0
          );

          existingWord.interval = interval;
          existingWord.easeFactor = easeFactor;

          existingWord.nextReview = new Date(
            Date.now() +
              interval * 24 * 60 * 60 * 1000
          );
        } else {
          const {
            interval,
            easeFactor,
          } = sm2Update(
            1,
            2.5,
            Number(ws.score) || 0
          );

          progress.words.push({
            wordId: ws.wordId,
            score: Number(ws.score) || 0,
            attempts: 1,
            correct: ws.correct ? 1 : 0,
            interval,
            easeFactor,
            nextReview: new Date(
              Date.now() +
                interval * 24 * 60 * 60 * 1000
            ),
          });
        }
      }
    }

    // Save progress after lesson + words update
    await progress.save();

    // ─── UPDATE USER ────────────────────────────────────────────────────────
    const user = req.user;

    // Current date at midnight
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    // Last active date
    const lastActive = user.lastActiveDate
      ? new Date(user.lastActiveDate)
      : null;

    if (lastActive) {
      lastActive.setHours(0, 0, 0, 0);

      const diffDays = Math.floor(
        (today.getTime() - lastActive.getTime()) /
          (1000 * 60 * 60 * 24)
      );

      // First activity on a new day
      if (diffDays === 1) {
        user.streak += 1;
      }

      // User missed one or more days
      else if (diffDays > 1) {
        user.streak = 1;
      }

      // diffDays === 0
      // Same day -> don't increase streak
    } else {
      // First ever activity
      user.streak = 1;
    }

    // Save today's activity
    user.lastActiveDate = new Date();

    // ─── UPDATE XP ──────────────────────────────────────────────────────────
    const earnedXp = xpEarned || lesson.xpReward;

    user.xp += earnedXp;

    user.level = Math.floor(user.xp / 200) + 1;

    // ─── UPDATE COMPLETED LESSON COUNT ──────────────────────────────────────
    user.lessonsCompleted = progress.lessons.filter(
      (lessonProgress) => lessonProgress.completed
    ).length;

    // ─── UPDATE LEARNED WORD COUNT ──────────────────────────────────────────
    //
    // Count unique words from completed lessons.
    //
    const completedLessonIds = progress.lessons
      .filter((lessonProgress) => lessonProgress.completed)
      .map((lessonProgress) => lessonProgress.lessonId);

    user.wordsLearned = await Word.countDocuments({
      lessonId: {
        $in: completedLessonIds,
      },
    });

    // ─── UPDATE DAILY XP ────────────────────────────────────────────────────
    const xpDate = progress.dailyXpDate
      ? new Date(progress.dailyXpDate)
      : null;

    if (xpDate) {
      xpDate.setHours(0, 0, 0, 0);
    }

    if (
      !xpDate ||
      xpDate.getTime() !== today.getTime()
    ) {
      progress.dailyXp = earnedXp;
      progress.dailyXpDate = new Date();
    } else {
      progress.dailyXp += earnedXp;
    }

    // Save progress + user
    await progress.save();
    await user.save();

    // ─── RESPONSE ───────────────────────────────────────────────────────────
    res.status(200).json({
      success: true,
      message: 'Lesson completed!',

      user: {
        xp: user.xp,
        level: user.level,
        streak: user.streak,
        lessonsCompleted: user.lessonsCompleted,
        wordsLearned: user.wordsLearned,
      },

      dailyXp: progress.dailyXp,
      dailyGoalXp: user.dailyGoalXp,
    });
  } catch (error) {
    console.error('Complete Lesson Error:', error);
    next(error);
  }
};

// ─── SM-2 ALGORITHM ───────────────────────────────────────────────────────────
const sm2Update = (
  interval,
  easeFactor,
  score
) => {
  // Convert score 0-100 into quality 0-5
  const q = Math.round(
    (score / 100) * 5
  );

  let newInterval = interval;
  let newEase = easeFactor;

  if (q >= 3) {
    if (interval === 1) {
      newInterval = 1;
    } else if (interval === 2) {
      newInterval = 6;
    } else {
      newInterval = Math.round(
        interval * easeFactor
      );
    }

    newEase =
      easeFactor +
      (
        0.1 -
        (5 - q) *
          (0.08 + (5 - q) * 0.02)
      );
  } else {
    newInterval = 1;
  }

  newEase = Math.max(
    1.3,
    newEase
  );

  return {
    interval: newInterval,
    easeFactor: newEase,
  };
};

// ─── EXPORTS ──────────────────────────────────────────────────────────────────
module.exports = {
  getLessons,
  getLessonWords,
  completeLesson,
};