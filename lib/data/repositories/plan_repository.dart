import 'network/api_service.dart';

class PlanRepository {
  final ApiService _apiService = ApiService();

  Future<List<Map<String, dynamic>>> fetchPlans() async {
    final response = await _apiService.fetchPlans();
    return response?['data'] ?? [];
  }
}
