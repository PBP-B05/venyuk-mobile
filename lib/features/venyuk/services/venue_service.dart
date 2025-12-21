import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/venue_model.dart';

class VenueService {
  static const baseUrl = 'http://127.0.0.1:8000/';

  static Future<List<Venue>> fetchVenues({
    String? query,
    String? category,
    int? minPrice,
    int? maxPrice,
  }) async {
    final params = <String, String>{};

    if (query != null && query.isNotEmpty) {
      params['q'] = query;
    }

    if (category != null && category.isNotEmpty) {
      params['category'] = category;
    }

    if (minPrice != null) {
      params['min_price'] = minPrice.toString();
    }

    if (maxPrice != null) {
      params['max_price'] = maxPrice.toString();
    }

    final uri = Uri.parse('${baseUrl}venue_api/')
        .replace(queryParameters: params);

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load venues');
    }

    final List<dynamic> data = jsonDecode(response.body);
    return data.map((v) => Venue.fromJson(v)).toList();
  }
}
