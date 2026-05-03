import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Ganti dengan IP kamu saat test di HP fisik
  // Kalau pakai emulator Android: 10.0.2.2:8000
  // Kalau pakai HP fisik: IP komputer kamu, contoh: 192.168.1.5:8000
  static const String baseUrl = 'http://192.168.100.8:8000/api';

  // ── Simpan & ambil token ──────────────────────────
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  // ── Header dengan token ───────────────────────────
  static Future<Map<String, String>> _authHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ── AUTH ──────────────────────────────────────────
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'email': email, 'password': password}),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password,
      }),
    );
    return jsonDecode(res.body);
  }

  // ── PRODUK ────────────────────────────────────────
  static Future<List<dynamic>> getProducts({
    String? kategori,
    String? search,
  }) async {
    String url = '$baseUrl/products';
    final params = <String>[];
    if (kategori != null && kategori != 'Semua')
      params.add('kategori=$kategori');
    if (search != null && search.isNotEmpty) params.add('search=$search');
    if (params.isNotEmpty) url += '?' + params.join('&');

    final res = await http.get(
      Uri.parse(url),
      headers: {'Accept': 'application/json'},
    );
    final data = jsonDecode(res.body);
    return data['products'] ?? [];
  }

  static Future<Map<String, dynamic>> getProductDetail(int id) async {
    final res = await http.get(
      Uri.parse('$baseUrl/products/$id'),
      headers: {'Accept': 'application/json'},
    );
    return jsonDecode(res.body);
  }

  // ── CART ──────────────────────────────────────────
  static Future<Map<String, dynamic>> getCart() async {
    final res = await http.get(
      Uri.parse('$baseUrl/cart'),
      headers: await _authHeaders(),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> addToCart(
    int productId,
    String ukuran,
    int jumlah,
  ) async {
    final res = await http.post(
      Uri.parse('$baseUrl/cart/add'),
      headers: await _authHeaders(),
      body: jsonEncode({
        'product_id': productId,
        'ukuran': ukuran,
        'jumlah': jumlah,
      }),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> removeFromCart(int cartItemId) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/cart/$cartItemId'),
      headers: await _authHeaders(),
    );
    return jsonDecode(res.body);
  }

  // ── WISHLIST ──────────────────────────────────────
  static Future<Map<String, dynamic>> toggleWishlist(int productId) async {
    final res = await http.post(
      Uri.parse('$baseUrl/wishlist/toggle'),
      headers: await _authHeaders(),
      body: jsonEncode({'product_id': productId}),
    );
    return jsonDecode(res.body);
  }

  // ── ORDER ─────────────────────────────────────────
  static Future<Map<String, dynamic>> getOrders() async {
    final res = await http.get(
      Uri.parse('$baseUrl/orders'),
      headers: await _authHeaders(),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> createOrder(
    String alamat,
    String kurir,
    String metodePembayaran,
  ) async {
    final res = await http.post(
      Uri.parse('$baseUrl/orders/create'),
      headers: await _authHeaders(),
      body: jsonEncode({
        'alamat_pengiriman': alamat,
        'kurir': kurir,
        'metode_pembayaran': metodePembayaran,
      }),
    );
    return jsonDecode(res.body);
  }

  //PROFILE
  static Future<Map<String, dynamic>> profile() async {
    final res = await http.get(
      Uri.parse('$baseUrl/auth/profile'),
      headers: await _authHeaders(),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> logout() async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/logout'),
      headers: await _authHeaders(),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> getWishlist() async {
    final res = await http.get(
      Uri.parse('$baseUrl/wishlist'),
      headers: await _authHeaders(),
    );
    return jsonDecode(res.body);
  }
}
