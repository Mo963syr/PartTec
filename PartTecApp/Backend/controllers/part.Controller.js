const part = require('../models/part.Model');
const cloudinary = require('../utils/cloudinary');


const mongoose = require('mongoose');

exports.deletePart = async (req, res) => {
  try {
    const { partId } = req.body;


    if (!mongoose.Types.ObjectId.isValid(partId) || !partId ) {
      return res.status(400).json({ error: '❌ معرف القطعة غير صالح' });
    }
    const deletedPart = await part.findByIdAndDelete(partId);

    if (!deletedPart) {
      return res.status(404).json({ error: '❌ لم يتم العثور على القطعة' });
    }

    res.status(200).json({
      message: '✅ تم حذف القطعة بنجاح',
      deletedPart: deletedPart,
    });
  } catch (error) {
    console.error('❌ خطأ أثناء حذف القطعة:', error);
    res.status(500).json({ error: 'فشل في حذف القطعة بسبب خطأ داخلي' });
  }
};

exports.viewPrivateParts = async (req, res) => {
  try {
    const { userid } = req.body;

    let parts;

    if (!userid || userid.trim() === '') {
      parts = await part.find();
    } else {
      parts = await part.find({ user: userid });
    }

    res.status(200).json({
      message: '✅ تم جلب القطع بنجاح',
      parts: parts,
    });
  } catch (error) {
    console.error('❌ خطأ أثناء جلب القطع:', error);
    res.status(500).json({ error: 'فشل في جلب القطع' });
  }
};

exports.addPart = async (req, res) => {
  try {
    const { name, manufacturer, model, year, category, Status, user } =
      req.body;
    let imageUrl = req.file ? req.file.path : null; // Changed from const to let

    if (req.file) {
      const result = await cloudinary.uploader.upload(req.file.path);
      imageUrl = result.secure_url; // Now this works because imageUrl is let
    }

    const newPart = new part({
      name,
      manufacturer,
      model,
      year,
      category,
      Status,
      user,
      imageUrl,
    });

    await newPart.save();

    res.status(201).json({
      message: '✅ تم إضافة المنتج',
      part: newPart,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: '❌ فشل في إضافة المنتج' });
  }
};
