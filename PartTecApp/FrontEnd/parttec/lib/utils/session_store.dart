import 'package:shared_preferences/shared_preferences.dart';

class SessionStore {
  static const _kUserId = 'userId';
  static const _kRole   = 'role';

  /// حفظ الجلسة
  static Future<void> save({
    required String userId,
    required String role,
  }) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kUserId, userId);
    await sp.setString(_kRole, role);
  }

  /// جلب المعرف والرول
  static Future<String?> userId() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_kUserId);
  }

  static Future<String?> role() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_kRole);
  }

  /// هل توجد جلسة محفوظة؟
  static Future<bool> hasSession() async {
    final sp = await SharedPreferences.getInstance();
    return sp.containsKey(_kUserId);
  }

  /// حذف الجلسة
  static Future<void> clear() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kUserId);
    await sp.remove(_kRole);
  }
}
