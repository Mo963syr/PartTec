const mongoose = require('mongoose');

const part = new mongoose.Schema(
  {
    name: {
      // ✅ أصلحت الخطأ الإملائي من naem إلى name
      type: String,
      required: [true, ' يجب إدخال اسم القطعة'],
    },
    manufacturer: {
      type: String,
      enum: {
        values: [
          'Hyundai',
          'All',
          'Acura',
          'Alfa Romeo',
          'Aston Martin',
          'Audi',
          'Bentley',
          'BMW',
          'Bugatti',
          'Buick',
          'Cadillac',
          'Chevrolet',
          'Chrysler',
          'Citroën',
          'Dacia',
          'Dodge',
          'Ferrari',
          'Fiat',
          'Ford',
          'Genesis',
          'GMC',
          'Honda',
          'Infiniti',
          'Jaguar',
          'Jeep',
          'Kia',
          'Koenigsegg',
          'Lamborghini',
          'Land Rover',
          'Lexus',
          'Lucid',
          'Maserati',
          'Mazda',
          'McLaren',
          'Mercedes-Benz',
          'Mini',
          'Mitsubishi',
          'Nissan',
          'Opel',
          'Peugeot',
          'Porsche',
          'Renault',
          'Rolls-Royce',
          'Saab',
          'Seat',
          'Škoda',
          'Subaru',
          'Suzuki',
          'Tesla',
          'Toyota',
          'Volkswagen',
          'Volvo',
        ],
        message: 'اختر نوع شركة مناسب',
      },
      required: [true, ' يجب إدخال اسم الصانع'],
    },
    model: {
      type: String,
      required: [true, ' يجب إدخال اسم الطراز أو السلسلة'],
    },
    year: {
      type: Number,
      validate: {
        validator: function (value) {
          return value >= 2000 && value <= 2025;
        },
        message: 'سنة الصنع يجب أن تكون بين 2000 و 2025',
      },
      required: [true, ' يجب إدخال سنة الصنع'],
    },
    category: {
      type: String,

      required: [true, ' يجب اختيار نوع الوقود'],
    },
    Status: {
      type: String,
      enum: { values: ['مستعمل', 'جديد'] },

      required: [true, ' يجب اختيار حالة القطعة'],
    },
    imageUrl: { type: String },
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: [true, 'يجب ربط القطعة بمعرف المستخدم'],
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model('Part', part);
