const express = require('express');
const router = express.Router();
const carController = require('../controllers/carController');

router.post('/add/:userId', carController.addCarToUser);

module.exports = router;