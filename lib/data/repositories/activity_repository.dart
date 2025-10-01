import 'dart:io';
import 'dart:async';
import 'network/api_service.dart';
import 'package:flutter/material.dart';

class ActivityRepository {
  final ApiService _apiService = ApiService();

  Future<List<Map<String, dynamic>>> fetchActivities() async {
    final response = await _apiService.fetchActivities();
    return response?['data']?.map((activity) {
          return {
            ...activity,
            'assignedForToday': activity['assignedForToday'] ?? false,
            'color': Color(int.parse(
                activity['color'] ?? '0xFF0067AC')), // Color por defecto
          };
        }).toList() ??
        [];
  }

  Future<List<Map<String, dynamic>>> fetchTodayActivities() async {
    try {
      debugPrint('🔍 [Repository] Fetching today activities...');
      final response = await _apiService.fetchTodayActivities();
      debugPrint('📡 [Repository] Received response: $response');

      if (response != null && response['status'] == true) {
        final activities =
            List<Map<String, dynamic>>.from(response['data'] ?? []);
        debugPrint('✅ [Repository] Processing ${activities.length} activities');

        if (activities.isEmpty) {
          debugPrint('ℹ️ [Repository] No activities scheduled for today');
          return [];
        }

        return activities
            .map((activity) => {
                  'id': activity['id'] ?? '',
                  'title': activity['title'] ?? 'Sin título',
                  'category': activity['category'] ?? 'General',
                  'color': activity['color'] ?? '0xFF0067AC',
                  'instructions':
                      List<String>.from(activity['instructions'] ?? []),
                  'duration': activity['duration'] ?? 300,
                  'type': activity['type'] ?? 'basic',
                  'assignedForToday': true,
                })
            .toList();
      }

      debugPrint('⚠️ [Repository] Invalid response format');
      return [];
    } catch (e) {
      debugPrint('❌ [Repository] Error: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchActiveProcesses(
      List activities) async {
    try {
      final body = {'ids': activities};
      final response = await _apiService.postActivities(body);

      if (response != null && response['status'] == true) {
        final processes =
            List<Map<String, dynamic>>.from(response['data'] ?? []);
        return processes;
      }
      return [];
    } catch (e) {
      debugPrint('❌ [Repository] Error: $e');
      if (e is SocketException) {
        throw Exception(
            'Error de conexión al servidor. Por favor, verifica tu conexión a internet.');
      } else if (e is TimeoutException) {
        throw Exception(
            'La conexión al servidor tardó demasiado. Por favor, inténtalo de nuevo.');
      }
      throw Exception(
          'Ocurrió un error al obtener los procesos. Por favor, inténtalo más tarde.');
    }
  }

  fetchRecentActiveProcesses(String grupo) async {
    try {
      final response =
          await _apiService.get('/admin/categorias/get-by-ids/$grupo');

      if (response != null && response['status'] == true) {
        final processes = Map<String, dynamic>.from(response['data'] ?? []);
        return processes;
      }
      return [];
    } catch (e) {
      debugPrint('❌ [Repository] Error: $e');
      if (e is SocketException) {
        throw Exception(
            'Error de conexión al servidor. Por favor, verifica tu conexión a internet.');
      } else if (e is TimeoutException) {
        throw Exception(
            'La conexión al servidor tardó demasiado. Por favor, inténtalo de nuevo.');
      }
      throw Exception(
          'Ocurrió un error al obtener los procesos. Por favor, inténtalo más tarde.');
    }
  }
}
