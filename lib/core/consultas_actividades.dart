import 'package:ecoapp/data/repositories/activity_repository.dart';

class ConsultasActividades {
  final ActivityRepository _activityRepository = ActivityRepository();

  Future<List> cargarActividades(List activities) async {
    try {
      final result = await _activityRepository.fetchActiveProcesses(activities);
      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> cargarActividadReciente(String grupo) async {
    try {
      final result = await _activityRepository.fetchRecentActiveProcesses(grupo);
      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> guardarPlanReciente(
      String userId, String processId, String groupId) async {
    try {
      await _activityRepository.saveRecentPlan(userId, processId, groupId);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> cargarPlanReciente(String userId, String groupId) async {
    try {
      final result = await _activityRepository.fetchRecentPlan(userId, groupId);
      return result;
    } catch (e) {
      rethrow;
    }
  }
}
