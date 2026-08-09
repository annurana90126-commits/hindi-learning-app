const router = require('express').Router();
const {
  getLessons,
  getLessonWords,
  completeLesson,
} = require('../controllers/lessonsController');
const { protect } = require('../middleware/auth');

// All lesson routes are protected
router.get('/', protect, getLessons);
router.get('/:lessonId/words', protect, getLessonWords);
router.post('/complete', protect, completeLesson);

module.exports = router;