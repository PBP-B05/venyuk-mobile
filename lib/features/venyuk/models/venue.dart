class Venue {
  final String id;
  final String name;
  final int price;
  final double rating;
  final bool isAvailable;
  final String imageUrl;
  final List<String> categories;
  final String address;

  Venue({
    required this.id,
    required this.name,
    required this.price,
    required this.rating,
    required this.isAvailable,
    required this.imageUrl,
    required this.categories,
    required this.address,
  });

  factory Venue.fromJson(Map<String, dynamic> json) {
    return Venue(
      id: json['id'],
      name: json['name'],
      price: json['price'],
      rating: (json['rating'] ?? 0).toDouble(),
      isAvailable: json['is_available'],
      imageUrl: json['image_url'] ?? '',
      categories: List<String>.from(json['categories_list'] ?? []),
      address: json['address'] ?? '',
    );
  }
}
