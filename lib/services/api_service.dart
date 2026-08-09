import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String _serverKey = 'dulshop_server_url';

  static const String defaultBaseUrl =
      'http://192.168.0.102:8000';

  static Future<String> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(_serverKey) ?? defaultBaseUrl;
  }

  static Future<void> setBaseUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();

    url = url.trim();

    if (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }

    await prefs.setString(_serverKey, url);
  }

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      final baseUrl = await getBaseUrl();

      final response = await http.post(
        Uri.parse('$baseUrl/login.php'),
        body: {
          'email': email,
          'password': password,
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        "status": "error",
        "message": "Gagal terhubung ke server: $e"
      };
    }
  }

  static Future<Map<String, dynamic>> register(
      String namaLengkap,
      String email,
      String password,
      String telepon) async {
    try {
      final baseUrl = await getBaseUrl();

      final response = await http.post(
        Uri.parse('$baseUrl/register.php'),
        body: {
          'nama_lengkap': namaLengkap,
          'email': email,
          'password': password,
          'telepon': telepon,
          'role': 'buyer',
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        "status": "error",
        "message": "Gagal terhubung ke server: $e"
      };
    }
  }

  static Future<List<dynamic>> getProducts() async {
    try {
      final baseUrl = await getBaseUrl();

      final response = await http.get(
        Uri.parse('$baseUrl/get_products.php'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return data['products'] ?? data['data'] ?? [];
      }

      return [];
    } catch (e) {
      return [];
    }
  }
}
