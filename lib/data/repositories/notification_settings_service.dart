import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecoapp/data/repositories/network/api_service.dart';

class NotificationSettingsService {
  final ApiService _apiService = ApiService(); // Instancia de ApiService

  Future<bool> updateNotificationSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();
      final baseUrl = await _apiService.resolveBaseUrl();

      if (token == null) {
        throw Exception('No authentication token available');
      }

      final response = await Dio().patch(
        '$baseUrl/user/notification-settings',
        data: {
          "notificationsEnabled":
              prefs.getBool('notificacionesActivas') ?? true,
          "frequency": prefs.getString('frecuencia') ?? '1',
          "activeBreaks": prefs.getBool('pausasActivas') ?? true,
          "startHour": prefs.getInt('horaInicio_hour') ?? 8,
          "startMinute": prefs.getInt('horaInicio_minute') ?? 0,
          "endHour": prefs.getInt('horaFin_hour') ?? 17,
          "endMinute": prefs.getInt('horaFin_minute') ?? 0,
        },
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error updating notification settings: $e');
      return false;
    }
  }
}
