const express = require('express');
const router = express.Router();
const userController = require('../controllers/user.Controller');

router.post('/add', userController.addUser);

module.exports = router;