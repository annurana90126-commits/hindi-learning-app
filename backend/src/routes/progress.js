const router = require('express').Router();
const {
  getProgress,
  getReviewWords,
  saveReview,
} = require('../controllers/progressController');
const { protect } = require('../middleware/auth');

router.get('/', protect, getProgress);
router.get('/review-words', protect, getReviewWords);
router.post('/save-review', protect, saveReview);

module.exports = router;