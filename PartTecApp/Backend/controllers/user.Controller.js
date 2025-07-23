const User = require('../models/user.Model');
exports.addUser = async (req, res) => {
  try {
    const { name, email, password, phoneNumber } = req.body;

    const user = await User.create({
      name,
      email,
      password,
      phoneNumber,
    });

    await user.save();

    res.status(201).json({
      message: 'account created sucsses',
      user,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
