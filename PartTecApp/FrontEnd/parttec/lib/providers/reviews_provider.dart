import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/app_settings.dart';

class ReviewItem {
  final String id;
  final String userName;
  final int rating;
  final String comment;
  final DateTime createdAt;

  ReviewItem({
    required this.id,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory ReviewItem.fromJson(Map<String, dynamic> j) => ReviewItem(
        id: j['_id'] ?? '',
        userName: j['userId']?['name'] ?? j['user']?['name'] ?? 'مستخدم',
        rating: (j['rating'] ?? 0).toInt(),
        comment: j['comment'] ?? '',
        createdAt: DateTime.tryParse(j['createdAt'] ?? '') ?? DateTime.now(),
      );
}

class ReviewsProvider extends ChangeNotifier {
  bool isLoading = false;
  double averageRating = 0;
  int reviewsCount = 0;
  List<ReviewItem> reviews = [];

  Future<void> fetchPartReviews(String partId) async {
    isLoading = true;
    notifyListeners();
    try {
      final res = await http
          .get(Uri.parse('${AppSettings.serverurl}/reviews/part/$partId'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        averageRating = (data['part']?['averageRating'] ?? 0).toDouble();
        reviewsCount = (data['part']?['reviewsCount'] ?? 0).toInt();
        reviews = (data['reviews'] as List)
            .map((e) => ReviewItem.fromJson(e))
            .toList();
      } else {
        reviews = [];
        averageRating = 0;
        reviewsCount = 0;
      }
    } catch (e) {
      reviews = [];
      averageRating = 0;
      reviewsCount = 0;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> upsertReview({
    required String partId,
    required String userId,
    required int rating,
    required String comment,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('${AppSettings.serverurl}/reviews/upsert'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'partId': partId,
          'userId': userId,
          'rating': rating,
          'comment': comment,
        }),
      );
      if (res.statusCode == 200) {
        await fetchPartReviews(partId);
        return true;
      }
    } catch (_) {}
    return false;
  }
}
