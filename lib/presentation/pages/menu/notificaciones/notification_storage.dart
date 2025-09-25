// notification_storage.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_notification.dart';

class NotificationStorage {
  static const _key = "notifications";

  static Future<void> saveNotification(AppNotification notif) async {
    debugPrint("Saving notification: ${notif.toJson()}");
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    list.add(jsonEncode(notif.toJson()));
    await prefs.setStringList(_key, list);
  }

  static Future<List<AppNotification>> loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    return list
        .map((s) => AppNotification.fromJson(jsonDecode(s)))
        .toList()
        .reversed
        .toList();
  }
}
