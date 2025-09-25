import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecoapp/data/repositories/network/api_service.dart';

class NotificationSettingsService {
  final ApiService _apiService = ApiService(); // Instancia de ApiService

  Future<bool> updateNotificationSettings(id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();
      final baseUrl = await _apiService.resolveBaseUrl();

      if (token == null) {
        throw Exception('No authentication token available');
      }

      final response = await Dio().put(
        '$baseUrl/admin/notification-plans/interruptions/$id',
        data: {
          "notifiPauseActive": prefs.getBool('notificacionesActivas') ?? true,
          "frecuencia": prefs.getString('frecuencia') ?? '4',
          "notifiActive": prefs.getBool('pausasActivas') ?? true,
          "dateStart":
              '${(prefs.getString('horaInicio_hour') ?? '08')}:${prefs.getString('horaInicio_minute') ?? '00'}',
          "dateEnd":
              '${(prefs.getString('horaFin_hour') ?? '17')}:${prefs.getString('horaFin_minute') ?? '00'}',
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

  Future fetchNotificationSettings(String userId) async {
    try {
      final response = await _apiService
          .get('/admin/notification-plans/interruptions/$userId');
      return response['data'];
    } catch (e) {
      debugPrint('Error fetching notification settings: $e');
      return null;
    }
  }

  Future createNotificationChannel(id) async {
    try {
      await _apiService.postRequest('admin/notification-plans/interruptions', {
        "idUser": id,
        "dateEnd": "23:59",
        "dateStart": "00:00",
        "frecuencia": "4",
      });
    } catch (e) {
      debugPrint('Error requesting notification permission: $e');
      return null;
    }
  }
}
