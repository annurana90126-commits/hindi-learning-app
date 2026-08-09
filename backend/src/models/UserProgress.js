const mongoose = require('mongoose');

const wordProgressSchema = new mongoose.Schema({
  wordId: { type: mongoose.Schema.Types.ObjectId, ref: 'Word' },
  score: { type: Number, default: 0 },       // 0–100
  attempts: { type: Number, default: 0 },
  correct: { type: Number, default: 0 },
  nextReview: { type: Date, default: Date.now },
  interval: { type: Number, default: 1 },    // SRS interval in days
  easeFactor: { type: Number, default: 2.5 }, // SM-2 ease factor
});

const lessonProgressSchema = new mongoose.Schema({
  lessonId: { type: mongoose.Schema.Types.ObjectId, ref: 'Lesson' },
  completed: { type: Boolean, default: false },
  accuracy: { type: Number, default: 0 },
  xpEarned: { type: Number, default: 0 },
  completedAt: { type: Date },
});

const userProgressSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      unique: true,
    },
    lessons: [lessonProgressSchema],
    words: [wordProgressSchema],
    dailyXp: { type: Number, default: 0 },
    dailyXpDate: { type: Date, default: null },
  },
  { timestamps: true }
);

module.exports = mongoose.model('UserProgress', userProgressSchema);