const express = require('express');
const router = express.Router();
const upload = require('../middleware/upload');
const { addPart, viewPrivateParts } = require('../controllers/part.Controller');

router.post('/add', upload.single('image'), addPart);
router.get('/viewPrivateParts',viewPrivateParts);
module.exports = router;
