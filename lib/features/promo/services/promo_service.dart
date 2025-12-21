import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/promo.dart';

class PromoService {
  // Ganti dengan URL Django server Anda
  static const String baseUrl = 'http://127.0.0.1:8000';

  Future<List<Promo>> fetchPromos() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/promo/api/get_promos/'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> promosJson = data['promos'];
        return promosJson.map((json) => Promo.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load promos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching promos: $e');
    }
  }

  Future<Promo> getPromoDetail(String code) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/promo/$code/'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Promo.fromJson(data);
      } else {
        throw Exception('Failed to load promo detail');
      }
    } catch (e) {
      throw Exception('Error fetching promo detail: $e');
    }
  }
}