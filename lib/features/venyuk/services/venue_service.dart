import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/venue.dart';

class VenueService {
  static const baseUrl =
      'https://pbp.cs.ui.ac.id/web/project/muhammad.fattan';

  static Future<List<Venue>> fetchVenues({
    String? query,
    String? category,
    int? minPrice,
    int? maxPrice,
  }) async {
    final uri = Uri.parse('$baseUrl/venue/api/')
        .replace(queryParameters: {
      if (query != null) 'q': query,
      if (category != null) 'category': category,
      if (minPrice != null) 'min_price': minPrice.toString(),
      if (maxPrice != null) 'max_price': maxPrice.toString(),
    });

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load venues');
    }

    final data = jsonDecode(response.body);
    return (data['venues'] as List)
        .map((v) => Venue.fromJson(v))
        .toList();
  }
}
