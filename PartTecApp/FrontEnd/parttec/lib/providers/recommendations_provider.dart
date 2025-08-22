import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../utils/app_settings.dart';

class RecommendationsProvider extends ChangeNotifier {
  bool isLoading = false;
  String? lastError;

  String userId;
  RecommendationsProvider(this.userId);

  List<Map<String, dynamic>> _orders = [];
  List<Map<String, dynamic>> get orders => _orders;

  final Set<String> _busyIds = {};
  bool isBusy(String id) => _busyIds.contains(id);

  Future<bool> fetchMyRecommendationOrders({String? authToken}) async {
    isLoading = true;
    lastError = null;
    notifyListeners();

    final uri = Uri.parse(
      '${AppSettings.serverurl}/order/getUserBrandOrders/$userId',
    );

    try {
      final res = await http.get(uri, headers: {
        'Content-Type': 'application/json',
        if (authToken != null && authToken.isNotEmpty)
          'Authorization': 'Bearer $authToken',
      });

      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);

        final List list = decoded is List
            ? decoded
            : (decoded['orders'] as List? ?? const []);

        _orders = list.map((e) => Map<String, dynamic>.from(e as Map)).toList();

        isLoading = false;
        notifyListeners();
        return true;
      } else {
        lastError = 'فشل الجلب: ${res.statusCode} ${res.body}';
      }
    } catch (e) {
      lastError = 'خطأ اتصال: $e';
    }

    isLoading = false;
    notifyListeners();
    return false;
  }

  void setUserId(String id) {
    userId = id;
    notifyListeners();
  }

  String _normalizeStatus(dynamic v) {
    final s = (v ?? '').toString().trim();
    if (s.isEmpty) return 'قيد البحث';
    final low = s.toLowerCase();

    if (low == 'available') return 'موجودة';
    if (low == 'unavailable') return 'غير موجودة';
    if (low.contains('pending')) return 'قيد البحث';

    if (s.contains('موجود')) return 'موجودة';
    if (s.contains('غير موجود')) return 'غير موجودة';
    if (s.contains('قيد') || s.contains('بحث')) return 'قيد البحث';
    return s;
  }

  bool isPending(Map o) => _normalizeStatus(o['status']) == 'قيد البحث';
  bool isAvailable(Map o) => _normalizeStatus(o['status']) == 'موجودة';
  bool isUnavailable(Map o) => _normalizeStatus(o['status']) == 'غير موجودة';

  Future<bool> _setStatus({
    required String orderId,
    required String newStatusArabic,
    String? authToken,
  }) async {
    try {
      _busyIds.add(orderId);
      notifyListeners();

      final url = Uri.parse(
        '${AppSettings.serverurl}/order/recommendation/$orderId/status',
      );

      final statusEn = (newStatusArabic == 'موجودة')
          ? 'available'
          : (newStatusArabic == 'غير موجودة')
              ? 'unavailable'
              : 'pending';

      final res = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (authToken != null && authToken.isNotEmpty)
            'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'status': statusEn,
        }),
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final i =
            _orders.indexWhere((o) => (o['_id'] ?? '').toString() == orderId);
        if (i != -1) {
          final m = Map<String, dynamic>.from(_orders[i]);

          m['status'] = newStatusArabic;
          _orders[i] = m;
        }
        notifyListeners();
        return true;
      } else {
        lastError = 'فشل التحديث: ${res.statusCode} ${res.body}';
        notifyListeners();
        return false;
      }
    } catch (e) {
      lastError = 'خطأ اتصال: $e';
      notifyListeners();
      return false;
    } finally {
      _busyIds.remove(orderId);
      notifyListeners();
    }
  }

  Future<bool> markAvailable(String orderId, {String? authToken}) => _setStatus(
      orderId: orderId, newStatusArabic: 'موجودة', authToken: authToken);

  Future<bool> markUnavailable(String orderId, {String? authToken}) =>
      _setStatus(
          orderId: orderId,
          newStatusArabic: 'غير موجودة',
          authToken: authToken);

  Future<bool> markPending(String orderId, {String? authToken}) => _setStatus(
      orderId: orderId, newStatusArabic: 'قيد البحث', authToken: authToken);
}
