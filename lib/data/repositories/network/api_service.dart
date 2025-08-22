import 'dart:async';
import 'dart:developer' as developer;
import 'package:dio/dio.dart';

class ApiService {
  String? _cachedBaseUrl;

  Future<String> resolveBaseUrl() async {
    if (_cachedBaseUrl != null) {
      developer.log('✅ Usando URL base en caché: $_cachedBaseUrl',
          name: 'ApiService');
      return _cachedBaseUrl!;
    }

    try {
      developer.log('🔍 Solicitando IP dinámica al backend...',
          name: 'ApiService');
      final response = await Dio().get('http://localhost:4300/network-info');
      if (response.statusCode == 200 && response.data != null) {
        _cachedBaseUrl =
            'http://${response.data['ip']}:${response.data['port']}';
        developer.log('✅ Base URL resuelta: $_cachedBaseUrl',
            name: 'ApiService');
        return _cachedBaseUrl!;
      } else {
        developer.log(
            '❌ No se pudo obtener la IP del backend. Código: ${response.statusCode}',
            name: 'ApiService',
            level: 1000);
        throw Exception('No se pudo obtener la IP del backend.');
      }
    } catch (e) {
      developer.log('❌ Error al resolver la URL base: $e',
          name: 'ApiService', level: 1000);
      return 'http://localhost:4300'; // Valor predeterminado
    }
  }

  Future<bool> checkBackendHealth() async {
    try {
      final baseUrl = await resolveBaseUrl();
      developer.log('🔍 Verificando salud del backend en: $baseUrl/app-health',
          name: 'ApiService');

      final response = await Dio().get('$baseUrl/app-health');
      if (response.statusCode == 200 && response.data['status'] == true) {
        developer.log('✅ Backend está saludable.', name: 'ApiService');
        return true;
      } else {
        developer.log(
          '⚠️ Backend no está saludable. Código: ${response.statusCode}, Respuesta: ${response.data}',
          name: 'ApiService',
          level: 900,
        );
        return false;
      }
    } catch (e) {
      developer.log(
        '❌ Error al verificar la salud del backend: $e',
        name: 'ApiService',
        level: 1000,
      );
      return false;
    }
  }

  Future<void> testConnection() async {
    try {
      final response = await Dio().get('http://localhost:4300');
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

  Future<void> testConnectionWithLogs() async {
    try {
      final baseUrl = await resolveBaseUrl();
      final response = await Dio().get('$baseUrl/app-health');
      if (response.statusCode == 200 && response.data['status'] == true) {
        // Log verde con emoji de éxito
        developer.log('✅ Conexión al backend exitosa: ${response.data}',
            name: 'ApiService');
      } else {
        // Log rojo con emoji de error
        developer.log(
            '❌ Fallo en la conexión al backend: Código ${response.statusCode}',
            name: 'ApiService',
            level: 900);
      }
    } catch (e) {
      // Log rojo con emoji de error
      developer.log('❌ Error al conectar con el backend: $e',
          name: 'ApiService', level: 1000);
    }
  }

  Future<bool> checkConnectivity() async {
    return true; // Siempre retorna true en modo local
  }

  void dispose() {
    // Nada que cerrar en modo local
  }

  Future<Map<String, dynamic>?> postRequest(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final baseUrl = await resolveBaseUrl();
      final response = await Dio().post(
        '$baseUrl/$endpoint',
        data: body,
        options: Options(headers: {"Content-Type": "application/json"}),
      );
      if (response.statusCode == 200) {
        return {
          "success": true,
          "data": response.data,
        };
      } else {
        developer.log(
          '⚠️ Error en POST: Código ${response.statusCode}',
          name: 'ApiService',
        );
        return null;
      }
    } catch (e) {
      developer.log(
        '❌ Error en POST: $e',
        name: 'ApiService',
      );
      return null;
    }
  }

  Future<Map<String, dynamic>?> getStats() async {
    // Devuelve estadísticas simuladas
    return {
      "activities_done": 2,
      "total_activities": 5,
      "total_time": 120,
      "user": "Usuario Local"
    };
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

  Future<Map<String, dynamic>?> fetchActiveProcesses() async {
    // Devuelve procesos activos simulados
    return {
      "data": [
        {"id": 1, "process": "Carga de datos", "status": "activo"},
      ]
    };
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
}
