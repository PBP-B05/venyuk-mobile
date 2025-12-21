import 'dart:convert';

class Promo {
  final int id;
  final String title;
  final String description;
  final int amountDiscount;
  final String category;
  final String categoryDisplay;
  final int maxUses;
  final String startDate;
  final String endDate;
  final bool isActive;
  final String code;
  final String urlDetail;
  final String urlUpdate;
  final String urlDelete;

  Promo({
    required this.id,
    required this.title,
    required this.description,
    required this.amountDiscount,
    required this.category,
    required this.categoryDisplay,
    required this.maxUses,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.code,
    required this.urlDetail,
    required this.urlUpdate,
    required this.urlDelete,
  });

  factory Promo.fromJson(Map<String, dynamic> json) {
    return Promo(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      amountDiscount: json['amount_discount'],
      category: json['category'],
      categoryDisplay: json['category_display'],
      maxUses: json['max_uses'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      isActive: json['is_active'],
      code: json['code'],
      urlDetail: json['url_detail'],
      urlUpdate: json['url_update'],
      urlDelete: json['url_delete'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'amount_discount': amountDiscount,
      'category': category,
      'category_display': categoryDisplay,
      'max_uses': maxUses,
      'start_date': startDate,
      'end_date': endDate,
      'is_active': isActive,
      'code': code,
      'url_detail': urlDetail,
      'url_update': urlUpdate,
      'url_delete': urlDelete,
    };
  }
}