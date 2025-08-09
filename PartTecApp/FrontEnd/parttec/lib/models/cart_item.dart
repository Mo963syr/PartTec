import 'package:flutter/foundation.dart';

import 'part.dart';

class CartItem {
  final String? id;

  final Part part;

  final int quantity;

  CartItem({this.id, required this.part, required this.quantity});

  factory CartItem.fromJson(Map<String, dynamic> json) {
    final partJson = json['partId'];
    final part = partJson is Map<String, dynamic>
        ? Part.fromJson(partJson)
        : throw ArgumentError('Missing partId data in CartItem JSON');
    final quantity = json['quantity'] ?? 1;
    return CartItem(
      id: json['_id'] as String?,
      part: part,
      quantity: quantity is int ? quantity : 1,
    );
  }
}
