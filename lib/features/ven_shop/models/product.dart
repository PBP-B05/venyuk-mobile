class Product {
  final String id;
  final String title;
  final String content;
  final String category;
  final String? thumbnail;
  final int price;
  final double rating;
  final int stock;
  final int reviewer;
  final String brand;

  Product({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    this.thumbnail,
    required this.price,
    required this.rating,
    required this.stock,
    required this.reviewer,
    required this.brand,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      category: json['category'],
      thumbnail: json['thumbnail'],
      price: json['price'],
      rating: (json['rating'] as num).toDouble(),
      stock: json['stock'],
      reviewer: json['reviewer'],
      brand: json['brand'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'thumbnail': thumbnail,
      'price': price,
      'rating': rating,
      'stock': stock,
      'reviewer': reviewer,
      'brand': brand,
    };
  }
}