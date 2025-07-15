const express = require('express');
const mongoose = require('mongoose');
const carRoutes = require('./routes/carRoutes');

const app = express();
app.use(express.json());

app.use('/cars', carRoutes);

mongoose.connect('mongodb://localhost:27017/PartTec');

app.listen(3000, () => {
  console.log('الخادم يعمل على المنفذ 3000');
});
