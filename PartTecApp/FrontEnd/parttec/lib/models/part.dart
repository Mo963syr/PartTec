class Part {
  final String id;
  final String name;
  final String? manufacturer;
  final String model;
  final int year;
  final String fuelType;
  final String status;
  final double price;
  final String imageUrl;
  final String category;
  final String? serialNumber;
  final String? description;

  Part({
    required this.id,
    required this.name,
    this.manufacturer,
    required this.model,
    required this.year,
    required this.fuelType,
    required this.status,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.serialNumber,
    this.description,
  });

  factory Part.fromJson(Map<String, dynamic> json) {
    return Part(
      id: (json['_id'] ?? json['id'])?.toString() ?? '',
      name: json['name'] ?? '',
      manufacturer: json['manufacturer'],
      model: json['model'] ?? '',
      year: json['year'] is int
          ? json['year'] as int
          : int.tryParse(json['year']?.toString() ?? '0') ?? 0,
      fuelType: json['fuelType'] ?? json['fuel_type'] ?? '',
      status: json['status'] ?? '',
      price: json['price'] is num
          ? (json['price'] as num).toDouble()
          : double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      imageUrl: json['imageUrl'] ?? json['image_url'] ?? '',
      category: json['category'] ?? '',
      serialNumber: json['serialNumber'] ?? json['serial_number'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'manufacturer': manufacturer,
      'model': model,
      'year': year,
      'fuelType': fuelType,
      'status': status,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'serialNumber': serialNumber,
      'description': description,
    };
  }
}
