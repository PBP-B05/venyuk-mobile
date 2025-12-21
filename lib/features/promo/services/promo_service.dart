// =====================================
// FILE: lib/services/promo_service.dart
// =====================================

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/promo.dart';

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

  Future<bool> deletePromo(String code) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/promo/$code/delete/'),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error deleting promo: $e');
    }
  }

  Future<PromoElement> createPromo(Map<String, dynamic> promoData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/promo/create_flutter/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(promoData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        return PromoElement.fromJson(data);
      } else {
        throw Exception('Failed to create promo: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating promo: $e');
    }
  }

  Future<PromoElement> updatePromo(String code, Map<String, dynamic> promoData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/promo/$code/update/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(promoData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return PromoElement.fromJson(data);
      } else {
        throw Exception('Failed to update promo: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating promo: $e');
    }
  }
}