const express = require('express');
const mongoose = require('mongoose');
const carRoutes = require('./routes/car.Routes');
const userRoutes = require('./routes/user.Routes');
const partRoutes = require('./routes/part.Routes');

const app = express();
app.use(express.json());

app.use('/cars', carRoutes);
app.use('/user', userRoutes);
app.use('/part', partRoutes);

mongoose.connect('mongodb://localhost:27017/PartTec');

app.listen(3000, () => {
  console.log('الخادم يعمل على المنفذ 3000');
});
