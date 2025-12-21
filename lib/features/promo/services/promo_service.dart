// =====================================
// FILE: lib/services/promo_service.dart (UPDATE)
// =====================================

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:venyuk_mobile/features/promo/models/promo.dart';

class PromoService {
  static const String baseUrl = 'http://localhost:8000';

  Future<List<PromoElement>> fetchPromos() async {
    try {
      print('🔄 Fetching from: $baseUrl/promo/api/get_promos/');
      
      final response = await http.get(
        Uri.parse('$baseUrl/promo/api/get_promos/'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('📡 Response status: ${response.statusCode}');
      print('📦 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final promo = promoFromJson(response.body);
        print('✅ Successfully parsed ${promo.promos.length} promos');
        return promo.promos;
      } else {
        throw Exception('Failed to load promos: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error: $e');
      throw Exception('Error fetching promos: $e');
    }
  }

  Future<PromoElement> getPromoDetail(String code) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/promo/$code/'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return PromoElement.fromJson(data);
      } else {
        throw Exception('Failed to load promo detail');
      }
    } catch (e) {
      throw Exception('Error fetching promo detail: $e');
    }
  }

  Future<Map<String, dynamic>> createPromo(Map<String, dynamic> promoData) async {
    try {
      print('📝 Creating promo with data: $promoData');
      
      final response = await http.post(
        Uri.parse('$baseUrl/promo/api/create/'),  // Ubah ke /api/create/
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(promoData),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📦 Response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create promo: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updatePromo(String code, Map<String, dynamic> promoData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/promo/api/$code/update/'),  // Ubah ke /api/
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(promoData),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to update promo');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> deletePromo(String code) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/promo/api/$code/delete/'),  // Ubah ke /api/
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to delete promo');
      }
    } catch (e) {
      rethrow;
    }
  }
}