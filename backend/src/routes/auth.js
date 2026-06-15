const router = require('express').Router();
router.get('/test', (req, res) => res.json({ message: 'Auth route working' }));
module.exports = router;