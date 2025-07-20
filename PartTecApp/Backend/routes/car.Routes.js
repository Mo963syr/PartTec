const express = require('express');
const router = express.Router();
const carController = require('../controllers/car.Controller');

router.post('/add/:userId', carController.addCarToUser);
router.get('/veiwCars/:userId', carController.viewcar);

module.exports = router;