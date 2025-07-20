const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  name: {
    type: String,
    required: [true, 'يجب إدخال الاسم']
  },
  email: {
    type: String,
    required: [true, 'يجب إدخال البريد الإلكتروني'],
    unique: true,
    lowercase: true,
    match: [/\S+@\S+\.\S+/, 'بريد إلكتروني غير صالح']
  },
  password: {
    type: String,
    required: [true, 'يجب إدخال كلمة المرور'],
    minlength: [6, 'يجب أن تكون كلمة المرور على الأقل 6 أحرف']
  },
 phoneNumber: {
  type: String,
  required: [true, 'يجب إدخال رقم الموبايل'],
  match: [/^(?:\+963|00963|0)?9\d{8}$/, 'رقم الموبايل السوري غير صالح']
},
  createdAt: {
    type: Date,
    default: Date.now
  },
  cars: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Car'
  }]
});

module.exports = mongoose.model('User', userSchema);
