const mongoose = require('mongoose');
const carModel = require('./carModel');

const userSchema = new mongoose.Schema({
  name: {
    type: String,
    required: [true, 'يجب إدخال الاسم'],
  },
  email: {
    type: String,
    required: [true, 'يجب إدخال البريد الإلكتروني'],
    unique: true,
    lowercase: true,
    match: [/\S+@\S+\.\S+/, 'بريد إلكتروني غير صالح'],
  },
  password: {
    type: String,
    required: [true, 'يجب إدخال كلمة المرور'],
    minlength: [6, 'يجب أن تكون كلمة المرور على الأقل 6 أحرف'],
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
  carModel,
});

module.exports = mongoose.model('User', userSchema);
