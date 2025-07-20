const express = require('express');
const router = express.Router();
const upload = require('../middleware/upload');
const { addPart, viewParts } = require('../controllers/part.Controller');

router.post('/add', upload.single('image'), addPart);
router.get('/viewPrivateParts', viewParts);
module.exports = router;
