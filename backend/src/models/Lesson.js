const mongoose = require('mongoose');

const lessonSchema = new mongoose.Schema(
  {
    title: { type: String, required: true, trim: true },
    titleHindi: { type: String, required: true, trim: true },
    description: { type: String, required: true },
    unitNumber: { type: Number, required: true },
    lessonNumber: { type: Number, required: true },
    xpReward: { type: Number, default: 10 },
    isActive: { type: Boolean, default: true },
    order: { type: Number, required: true }, // global sort order
  },
  { timestamps: true }
);

module.exports = mongoose.model('Lesson', lessonSchema);