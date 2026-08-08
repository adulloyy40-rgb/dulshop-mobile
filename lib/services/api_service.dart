import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:8000';

  // Fungsi untuk Login
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login.php'),
        body: {'email': email, 'password': password},
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"status": "error", "message": "Gagal terhubung ke server: $e"};
    }
  }

  // Fungsi untuk Register
  static Future<Map<String, dynamic>> register(
      String namaLengkap, String email, String password, String telepon) async {
    try {
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
      return {"status": "error", "message": "Gagal terhubung ke server: $e"};
    }
  }

  // BARU: Fungsi untuk Mengambil Daftar Produk
  static Future<List<dynamic>> getProducts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get_products.php'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Menyesuaikan dengan struktur response dari backend PHP Anda
        return data['products'] ?? data['data'] ?? [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}

