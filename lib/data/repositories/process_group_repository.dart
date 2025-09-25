import 'package:ecoapp/data/repositories/network/api_service.dart';
import 'package:flutter/foundation.dart';

class ProcessGroupRepository {
  final _apiService = ApiService();
  Future<dynamic> fetchProcessGroups(String userId) async {
    final response = await _apiService.get('/admin/process-groups/$userId');
    return response['data'];
  }

  Future<void> saveActivities(List activities) async {
    activities.forEach((element) {
      debugPrint(element.toString());
    });
  }
}
