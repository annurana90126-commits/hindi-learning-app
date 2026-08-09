const mongoose = require('mongoose');

const wordSchema = new mongoose.Schema(
  {
    hindi: {
      type: String,
      required: true,
      trim: true,
    },
    english: {
      type: String,
      required: true,
      trim: true,
    },
    transliteration: {
      type: String,
      required: true,
      trim: true,
    },
    exampleHindi: { type: String, default: '' },
    exampleEnglish: { type: String, default: '' },
    difficulty: {
      type: String,
      enum: ['easy', 'medium', 'hard'],
      default: 'easy',
    },
    audioUrl: { type: String, default: '' },
    imageUrl: { type: String, default: '' },
    lessonId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Lesson',
      required: true,
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model('Word', wordSchema);