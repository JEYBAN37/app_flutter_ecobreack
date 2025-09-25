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

  Future<List> cargarActividadReciente(String grupo) async {
    try {
      final result = await _activityRepository.fetchRecentActiveProcesses(grupo);
      return result;
    } catch (e) {
      rethrow;
    }
  }
}
