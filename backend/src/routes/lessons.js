const router = require('express').Router();
router.get('/test', (req, res) => res.json({ message: 'Lessons route working' }));
module.exports = router;