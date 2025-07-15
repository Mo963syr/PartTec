const express = require('express');
const mongoose = require('mongoose');
const Product = require('./models/Product');
const Order = require('./models/Order');

const app = express();
app.use(express.json());

// الاتصال بقاعدة البيانات
mongoose.connect('mongodb://localhost:27017/market', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

// إضافة منتج جديد
app.post('/products', async (req, res) => {
  const { name, price, imageUrl }  = req.body;
  const newProduct = new Product({ name, price, imageUrl });
  await newProduct.save();
  res.status(201).json(newProduct);
});

// عرض كل المنتجات
app.get('/products', async (req, res) => {
  const products = await Product.find();
  res.status(200).json(products);
});

// إضافة طلب جديد
app.post('/orders', async (req, res) => {
  const { products, customerMessage } = req.body;
  const totalPrice = products.reduce(
    (total, product) => total + product.price,
    0
  );
  const order = new Order({ products, totalPrice, customerMessage });
  await order.save();
  res.status(201).json(order);
});

// عرض الطلبات
app.get('/orders', async (req, res) => {
  const orders = await Order.find().populate('products');
  res.status(200).json(orders);
});

// تحديث حالة الطلب
app.put('/orders/:id', async (req, res) => {
  const { status } = req.body;
  const order = await Order.findByIdAndUpdate(
    req.params.id,
    { status },
    { new: true }
  );
  res.status(200).json(order);
});

// بدء الخادم
const PORT = 3000;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
