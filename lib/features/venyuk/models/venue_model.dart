import 'dart:convert';

List<Venue> venueFromJson(String str) => List<Venue>.from(json.decode(str).map((x) => Venue.fromJson(x)));

String venueToJson(List<Venue> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Venue {
  final String id;
  final String name;
  final List<String> categories;
  final String address;
  final int price;
  final double rating;
  final String imageUrl;
  final bool isAvailable;

  Venue({
    required this.id,
    required this.name,
    required this.categories,
    required this.address,
    required this.price,
    required this.rating,
    required this.imageUrl,
    required this.isAvailable,
  });

  factory Venue.fromJson(Map<String, dynamic> json) {
    return Venue(
      id: json['id'],
      name: json['name'],
      categories: List<String>.from(json['category'] ?? []),
      address: json['address'] ?? '',
      price: json['price'] ?? 0,
      rating: (json['rating'] ?? 0).toDouble(),
      imageUrl: json['image_url'] ??
          'https://cdn.antaranews.com/cache/1200x800/2025/09/10/1000017960.jpg',
      isAvailable: json['is_available'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'categories': List<dynamic>.from(categories.map((x) => x)),
        'address': address,
        'price': price,
        'rating': rating,
        'image_url': imageUrl,
        'is_available': isAvailable,
      };
}
