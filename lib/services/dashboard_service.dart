import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:retailer_app/constants/config.dart';
import 'package:retailer_app/models/dashboard_model.dart';
import 'package:retailer_app/utils/shared_preferences.dart';

Future<Map<String, String>> _getAuthHeaders() async {
  final token = SharedPreferenceHelper.instance.getString(
    'token',
  );
  return {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
}

Future<DashboardData> fetchRetailerDashboardStats() async {
  final url = Uri.parse('${baseUrl}api/dashboard/retailer-stats');
  try {
    final headers = await _getAuthHeaders();
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonData = jsonDecode(response.body);
      return DashboardData.fromJson(jsonData);
    } else {
      print('Failed to fetch Dashboard stats: ${response.body}');
      throw Exception('Failed to fetch dashboard stats');
    }
  } catch (e) {
    print('Error fetching dashboard data: $e');
    rethrow;
  }
}
