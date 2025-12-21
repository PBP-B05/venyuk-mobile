class HistoryItem {
  final String id;
  final String productTitle;
  final int productPrice;
  final String? productImage;
  final String purchaseDate;

  HistoryItem({
    required this.id,
    required this.productTitle,
    required this.productPrice,
    this.productImage,
    required this.purchaseDate,
  });

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      id: json['id'],
      productTitle: json['product_title'],
      productPrice: json['product_price'],
      productImage: json['product_image'],
      purchaseDate: json['purchase_date'],
    );
  }
}