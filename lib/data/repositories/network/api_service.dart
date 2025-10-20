import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiService {
  String? _cachedBaseUrl;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static const _storage = FlutterSecureStorage();
  final http.Client _client = http.Client();
  final Duration _timeout = const Duration(seconds: 30);

  Future<String> resolveBaseUrl() async {
    if (_cachedBaseUrl != null) {
      developer.log('✅ Usando URL base en caché: $_cachedBaseUrl',
          name: 'ApiService');
      return _cachedBaseUrl!;
    }
    return 'https://backeco.onrender.com'; // Valor predeterminado
  }

  Future<bool> checkBackendHealth() async {
    return true; // Siempre retorna true en modo local
  }

  Future<void> testConnection() async {
    try {
      final response = await Dio().get('https://backeco.onrender.com');
      if (response.statusCode == 200) {
        developer.log('✅ Conexión al backend exitosa: ${response.data}',
            name: 'ApiService');
      } else {
        developer.log(
            '❌ Fallo en la conexión al backend: Código ${response.statusCode}',
            name: 'ApiService',
            level: 1000);
      }
    } catch (e) {
      developer.log('❌ Error al conectar con el backend: $e',
          name: 'ApiService', level: 1000);
    }
  }

  Future<void> testConnectionWithLogs() async {}

  Future<bool> checkConnectivity() async {
    return true; // Siempre retorna true en modo local
  }

  void dispose() {
    // Nada que cerrar en modo local
  }

  // ...existing code...
  Future<String?> postRequest(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final baseUrl = await resolveBaseUrl();
    try {
      final response = await Dio().post(
        '$baseUrl/$endpoint',
        data: body,
        options: Options(headers: {"Content-Type": "application/json"}),
      );
      return response.data['message']?.toString();
    } on DioException catch (e) {
      // Si el backend envía un JSON de error, lo retornamos
      if (e.response?.data is Map<String, dynamic>) {
        return e.response?.data['error']?.toString();
      }
      // Si no hay JSON, retornamos el mensaje de error
      return e.message;
    }
  }

// ...existing code...
  Future<Map<String, dynamic>?> getStats() async {
    final idUser = await _storage.read(key: 'admin_userId');
    final currentDate = DateTime.now();
    final formattedDate =
        "${currentDate.year.toString().padLeft(4, '0')}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')}";
    final response =
        await get('/admin/users/$idUser/stats?date=$formattedDate');
    return {
      "activities_done": response['data']['activities_done'],
      "total_activities": response['data']['total_activities'],
      "total_time": response['data']['total_time'],
    };
  }

  Future fetchUserExerciseHistory(String startDate, String endDate) async {
    final idUser = await _storage.read(key: 'admin_userId');
    final response = await get(
        '/user/exercise-history/$idUser/exercises?startDate=$startDate&endDate=$endDate');
    return response['data'];
  }

  Future fetchUserHistory() async {
    final idUser = await _storage.read(key: 'admin_userId');
    final response = await get('/user/exercise-history/$idUser/history');
    return response['data'];
  }

  Future<Map<String, dynamic>?> fetchActivities() async {
    // Devuelve actividades simuladas
    return {
      "data": [
        {"id": 1, "name": "Reciclar papel", "done": false},
        {"id": 2, "name": "Apagar luces", "done": true},
      ]
    };
  }

  Future<Map<String, dynamic>?> fetchPlans() async {
    // Devuelve planes simulados
    return {
      "data": [
        {"id": 1, "title": "Plan Verde", "active": true},
        {"id": 2, "title": "Plan Azul", "active": false},
      ]
    };
  }

  Future<Map<String, dynamic>?> fetchTodayActivities() async {
    // Devuelve actividades de hoy simuladas
    return {
      "data": [
        {"id": 1, "name": "Reciclar papel", "done": false},
      ]
    };
  }

  Future<Map<String, dynamic>?> postActivities(activities) async {
    try {
      final baseUrl = await resolveBaseUrl();
      final jsonBody = json.encode(activities);
      final token = await _storage.read(key: 'admin_token');
      final response = await Dio().post(
          '$baseUrl/admin/categorias/get-categories-with-exercises',
          data: jsonBody,
          options: Options(headers: {"Authorization": "Bearer $token"}));
      if (response.statusCode == 201 && response.data is Map<String, dynamic>) {
        return response.data;
      } else {
        debugPrint('Error: Código de estado ${response.statusCode}');
        return {
          'error': true,
          'message': 'Error en la respuesta del servidor',
          'statusCode': response.statusCode,
        };
      }
    } on DioException catch (e) {
      debugPrint('DioException: ${e.message}');
      return {
        'error': true,
        'message': e.message,
        'details': e.response?.data,
      };
    } catch (e) {
      debugPrint('Error inesperado: $e');
      return {
        'error': true,
        'message': 'Error inesperado',
        'details': e.toString(),
      };
    }
  }

  Future loadActivityToHistory(userData) async {
    try {
      final baseUrl = await resolveBaseUrl();
      final jsonBody = json.encode(userData);
      final token = await _storage.read(key: 'admin_token');
      final response = await Dio().post('$baseUrl/user/exercise-history',
          data: jsonBody,
          options: Options(headers: {"Authorization": "Bearer $token"}));
      if (response.statusCode == 201 && response.data is Map<String, dynamic>) {
        debugPrint('Actividad completada: ${response.data}');
        return response.data;
      } else {
        debugPrint('Error: Código de estado ${response.statusCode}');
        return {
          'error': true,
          'message': 'Error en la respuesta del servidor',
          'statusCode': response.statusCode,
        };
      }
    } on DioException catch (e) {
      debugPrint('DioException: ${e.message}');
      return {
        'error': true,
        'message': e.message,
        'details': e.response?.data,
      };
    } catch (e) {
      debugPrint('Error inesperado: $e');
      return {
        'error': true,
        'message': 'Error inesperado',
        'details': e.toString(),
      };
    }
  }

  Future loadActivityComplete(user, plan, group) async {
    try {
      final baseUrl = await resolveBaseUrl();
      final jsonBody = json.encode({
        'userId': user,
        'plan': plan,
        'grupo': group,
      });
      debugPrint('Cargando actividades para el grupo: $jsonBody');
      final token = await _storage.read(key: 'admin_token');
      final response = await Dio().post(
          '$baseUrl/user/exercise-history/by-user',
          data: jsonBody,
          options: Options(headers: {"Authorization": "Bearer $token"}));
      if (response.statusCode == 201 && response.data is Map<String, dynamic>) {
        debugPrint('Actividad completada: ${response.data}');
        return response.data;
      } else {
        debugPrint('Error: Código de estado ${response.statusCode}');
        return {
          'error': true,
          'message': 'Error en la respuesta del servidor',
          'statusCode': response.statusCode,
        };
      }
    } on DioException catch (e) {
      debugPrint('DioException: ${e.message}');
      return {
        'error': true,
        'message': e.message,
        'details': e.response?.data,
      };
    } catch (e) {
      debugPrint('Error inesperado: $e');
      return {
        'error': true,
        'message': 'Error inesperado',
        'details': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> getUserInfo() async {
    // Información llamativa para modo demo/local
    return {
      "id": 0,
      "name": "¡Modo DEMO!",
      "email": "sin_conexion@demo.com",
      "avatarUrl":
          "https://ui-avatars.com/api/?name=DEMO&background=FFA500&color=fff",
      "role": "demo",
      "bio":
          "Estás usando la app en modo local/demo. No hay conexión a internet ni datos reales.",
      "joined": "N/A",
      "location": "Sin conexión",
      "points": 0,
      "activities_done": 0,
      "total_activities": 0,
      "themeColor": "#FFA500", // Naranja llamativo
      "message": "¡Estás en modo DEMO! Disfruta probando la app sin conexión."
    };
  }

  Future<List<Map<String, dynamic>>> fetchPauseHistory() async {
    // Devuelve solo 2 pausas simuladas
    return [
      {
        "id": 1,
        "title": "Pausa de estiramiento",
        "description": "Estira brazos y espalda durante 2 minutos.",
        "timestamp": "2024-06-01 10:30:00",
        "status": "realizada"
      },
      {
        "id": 2,
        "title": "Pausa de respiración",
        "description": "Respira profundamente durante 1 minuto.",
        "timestamp": "2024-06-01 15:00:00",
        "status": "realizada"
      }
    ];
  }

  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? query,
  }) async {
    try {
      final baseUrl = await resolveBaseUrl();
      String? token = await _storage.read(key: 'admin_token');
      final Uri uri = Uri.parse(
        '$baseUrl$endpoint',
      ).replace(queryParameters: query);

      final requestHeaders = {
        'Content-Type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        ...?headers,
      };

      final response =
          await _client.get(uri, headers: requestHeaders).timeout(_timeout);

      debugPrint('🔍 GET $uri');

      // Handle authentication errors
      if (response.statusCode == 401) {
        developer.log(
            '🔒 Token inválido o expirado. Por favor, inicia sesión de nuevo.',
            name: 'ApiService',
            level: 900);
        throw Exception('Unauthorized');
      }

      final responseData = json.decode(response.body);
      if (response.statusCode == 200 && responseData['status'] == true) {
        return responseData;
      }
      throw Exception(
        responseData['message'] ?? 'Error en la respuesta del servidor',
      );
    } catch (e) {
      debugPrint('❌ Error en petición GET: $e');
      rethrow;
    }
  }
}
