// const mongoose = require('mongoose');

const Car = require('../models/car.Model');
const User = require('../models/user.Model');
exports.addCar = async (req, res) => {
  const { manufacturer, model, year, fuelType, user } = req.body;

  try {
    const newCar = new Car({ manufacturer, model, year, fuelType, user });
    await newCar.save();
    res.status(201).json({ message: '🚗 تم إضافة السيارة بنجاح', car: newCar });
  } catch (error) {
    res.status(400).json({ error: '❌ حدث خطأ أثناء إضافة السيارة' });
  }
};

exports.viewcar = async (req, res) => {
  const { userId } = req.params;

  try {
    const cars = await Car.find({ user: userId });
    res.status(200).json(cars);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: '❌ فشل في جلب السيارات' });
  }
};

exports.addCarToUser = async (req, res) => {
  try {
    const userId = req.params.userId;
    const { manufacturer, model, year, fuelType } = req.body;

    // التحقق من وجود المستخدم
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ message: 'المستخدم غير موجود' });
    }

    // إنشاء السيارة وربطها بالمستخدم
    const car = await Car.create({
      manufacturer,
      model,
      year,
      fuelType,
      user: userId,
    });

    // إضافة السيارة إلى المستخدم
    user.cars.push(car._id);
    await user.save();

    res.status(201).json({
      message: 'تمت إضافة السيارة بنجاح',
      car,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
