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

const uri =
  'mongodb+srv://moafaqaqeed01:JqphSStXpXgsv8t@cluster0.vhz1h.mongodb.net/PartTec?retryWrites=true&w=majority';

mongoose
  .connect(uri, { useNewUrlParser: true, useUnifiedTopology: true })
  .then(() => {
    console.log('✅ تم الاتصال بقاعدة بيانات PartTec في MongoDB Atlas');
  })
  .catch((err) => {
    console.error('❌ فشل الاتصال:', err);
  });

app.listen(3000, () => {
  console.log('الخادم يعمل على المنفذ 3000');
});
