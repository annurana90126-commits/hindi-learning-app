const router = require('express').Router();
router.get('/test', (req, res) => res.json({ message: 'Progress route working' }));
module.exports = router;