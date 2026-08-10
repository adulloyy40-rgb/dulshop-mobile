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

    while (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }

    await prefs.setString(_serverKey, url);
  }

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
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
        'status': 'error',
        'message': 'Gagal terhubung ke server: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> register(
    String namaLengkap,
    String email,
    String password,
    String telepon,
  ) async {
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
        'status': 'error',
        'message': 'Gagal terhubung ke server: $e',
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

  static Future<Map<String, dynamic>> addToCart({
    required int userId,
    required int productId,
    int quantity = 1,
    int? variantId,
  }) async {
    try {
      final baseUrl = await getBaseUrl();

      final response = await http.post(
        Uri.parse('$baseUrl/add_to_cart.php'),
        body: {
          'user_id': userId.toString(),
          'product_id': productId.toString(),
          'quantity': quantity.toString(),
          if (variantId != null)
            'variant_id': variantId.toString(),
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Gagal terhubung ke server: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> getCart(
    int userId,
  ) async {
    try {
      final baseUrl = await getBaseUrl();

      final response = await http.get(
        Uri.parse(
          '$baseUrl/get_cart.php?user_id=$userId',
        ),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return {
        'status': 'error',
        'message': 'Gagal mengambil data keranjang.',
      };
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Gagal terhubung ke server: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> createOrder({
    required int userId,
    String alamatPengiriman = 'Alamat default',
    double biayaPengiriman = 0,
  }) async {
    try {
      final baseUrl = await getBaseUrl();

      final response = await http.post(
        Uri.parse('$baseUrl/create_order.php'),
        body: {
          'user_id': userId.toString(),
          'alamat_pengiriman': alamatPengiriman,
          'biaya_pengiriman':
              biayaPengiriman.toString(),
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return {
        'status': 'error',
        'message': 'Gagal melakukan checkout.',
      };
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Gagal terhubung ke server: $e',
      };
    }
  }
  static Future<List<dynamic>> getAddresses(int userId) async {
    try {
      final baseUrl = await getBaseUrl();

      final response = await http.get(
        Uri.parse(
          '$baseUrl/get_addresses.php?user_id=$userId',
        ),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);

        if (result['status'] == 'success') {
          return result['data'] ?? [];
        }
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> addAddress({
    required int userId,
    required String labelAlamat,
    required String alamatLengkap,
    required String kota,
    String kodepos = '',
    int isUtama = 0,
  }) async {
    try {
      final baseUrl = await getBaseUrl();

      final response = await http.post(
        Uri.parse('$baseUrl/add_address.php'),
        body: {
          'user_id': userId.toString(),
          'label_alamat': labelAlamat,
          'alamat_lengkap': alamatLengkap,
          'kota': kota,
          'kodepos': kodepos,
          'is_utama': isUtama.toString(),
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return {
        'status': 'error',
        'message': 'Gagal menambahkan alamat.',
      };
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Gagal terhubung ke server: $e',
      };
    }
  }}
