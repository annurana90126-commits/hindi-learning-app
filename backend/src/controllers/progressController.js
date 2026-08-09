const UserProgress = require('../models/UserProgress');
const Word = require('../models/Word');
const User = require('../models/User');

// ─── GET FULL PROGRESS STATS ──────────────────────────────────────────────────
const getProgress = async (req, res, next) => {
  try {
    const user = req.user;
    const progress = await UserProgress.findOne({ userId: user._id });

    if (!progress) {
      return res.status(200).json({
        success: true,
        stats: {
          xp: user.xp,
          level: user.level,
          streak: user.streak,
          wordsLearned: 0,
          lessonsCompleted: 0,
          dailyXp: 0,
          dailyGoalXp: user.dailyGoalXp,
          accuracy: 0,
          weeklyXp: Array(7).fill(0),
        },
      });
    }

    // Calculate average accuracy
    const completedLessons = progress.lessons.filter((l) => l.completed);
    const avgAccuracy =
      completedLessons.length > 0
        ? Math.round(
            completedLessons.reduce((sum, l) => sum + l.accuracy, 0) /
              completedLessons.length
          )
        : 0;

    // Build weekly XP (last 7 days)
    const weeklyXp = Array(7).fill(0);
    const today = new Date();
    for (const lesson of completedLessons) {
      if (!lesson.completedAt) continue;
      const diffDays = Math.floor(
        (today - new Date(lesson.completedAt)) / (1000 * 60 * 60 * 24)
      );
      if (diffDays < 7) {
        weeklyXp[6 - diffDays] += lesson.xpEarned || 0;
      }
    }

    // Words due for review today
    const now = new Date();
    const wordsDueToday = progress.words.filter(
      (w) => new Date(w.nextReview) <= now
    ).length;

    res.status(200).json({
      success: true,
      stats: {
        xp: user.xp,
        level: user.level,
        streak: user.streak,
        wordsLearned: user.wordsLearned,
        lessonsCompleted: user.lessonsCompleted,
        dailyXp: progress.dailyXp,
        dailyGoalXp: user.dailyGoalXp,
        accuracy: avgAccuracy,
        weeklyXp,
        wordsDueToday,
        totalWordsTracked: progress.words.length,
      },
    });
  } catch (error) {
    next(error);
  }
};

// ─── GET WORDS DUE FOR REVIEW ─────────────────────────────────────────────────
const getReviewWords = async (req, res, next) => {
  try {
    const progress = await UserProgress.findOne({ userId: req.user._id });

    if (!progress || progress.words.length === 0) {
      return res.status(200).json({
        success: true,
        words: [],
        message: 'No words due for review yet. Complete some lessons first!',
      });
    }

    // Get words due today
    const now = new Date();
    const dueWordProgress = progress.words.filter(
      (w) => new Date(w.nextReview) <= now
    );

    if (dueWordProgress.length === 0) {
      return res.status(200).json({
        success: true,
        words: [],
        message: 'No words due today. Come back later!',
      });
    }

    // Fetch actual word data
    const wordIds = dueWordProgress.map((w) => w.wordId);
    const words = await Word.find({ _id: { $in: wordIds } });

    const result = words.map((word) => {
      const wp = dueWordProgress.find(
        (w) => w.wordId.toString() === word._id.toString()
      );
      return {
        id: word._id,
        hindi: word.hindi,
        english: word.english,
        transliteration: word.transliteration,
        exampleHindi: word.exampleHindi,
        exampleEnglish: word.exampleEnglish,
        difficulty: word.difficulty,
        score: wp?.score || 0,
        interval: wp?.interval || 1,
      };
    });

    res.status(200).json({
      success: true,
      words: result,
      count: result.length,
    });
  } catch (error) {
    next(error);
  }
};

// ─── SAVE REVIEW RESULTS ──────────────────────────────────────────────────────
const saveReview = async (req, res, next) => {
  try {
    const { wordScores } = req.body;

    if (!wordScores || wordScores.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'wordScores array is required',
      });
    }

    const progress = await UserProgress.findOne({ userId: req.user._id });
    if (!progress) {
      return res.status(404).json({
        success: false,
        message: 'No progress found',
      });
    }

    let xpEarned = 0;

    for (const ws of wordScores) {
      const wordProgress = progress.words.find(
        (w) => w.wordId.toString() === ws.wordId
      );

      if (wordProgress) {
        wordProgress.attempts += 1;
        if (ws.correct) {
          wordProgress.correct += 1;
          xpEarned += 2;
        }
        wordProgress.score = Math.round(
          (wordProgress.correct / wordProgress.attempts) * 100
        );

        // SM-2 update
        const { interval, easeFactor } = sm2Update(
          wordProgress.interval,
          wordProgress.easeFactor,
          ws.score
        );
        wordProgress.interval = interval;
        wordProgress.easeFactor = easeFactor;
        wordProgress.nextReview = new Date(
          Date.now() + interval * 24 * 60 * 60 * 1000
        );
      }
    }

    await progress.save();

    // Add XP to user
    const user = req.user;
    user.xp += xpEarned;
    user.level = Math.floor(user.xp / 200) + 1;
    await user.save();

    res.status(200).json({
      success: true,
      message: 'Review saved!',
      xpEarned,
      user: {
        xp: user.xp,
        level: user.level,
        streak: user.streak,
      },
    });
  } catch (error) {
    next(error);
  }
};

// ─── SM-2 ALGORITHM ───────────────────────────────────────────────────────────
const sm2Update = (interval, easeFactor, score) => {
  const q = Math.round((score / 100) * 5);
  let newInterval = interval;
  let newEase = easeFactor;

  if (q >= 3) {
    if (interval === 1) newInterval = 1;
    else if (interval === 2) newInterval = 6;
    else newInterval = Math.round(interval * easeFactor);
    newEase = easeFactor + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02));
  } else {
    newInterval = 1;
  }

  newEase = Math.max(1.3, newEase);
  return { interval: newInterval, easeFactor: newEase };
};

module.exports = { getProgress, getReviewWords, saveReview };