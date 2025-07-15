// const mongoose = require('mongoose');
const Car = require('../models/carModel');

exports.addCar = async (req, res) => {
  const { manufacturer, model, year, fuelType,user } = req.body;
  
  try {
    const newCar = new Car({ manufacturer, model, year, fuelType ,user});
    await newCar.save();
    res.status(201).json({ message: '🚗 تم إضافة السيارة بنجاح', car: newCar });
  } catch (error) {
    res.status(400).json({ error: '❌ حدث خطأ أثناء إضافة السيارة' });
  }
};
