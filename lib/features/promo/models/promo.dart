// To parse this JSON data, do
//
//     final promo = promoFromJson(jsonString);

import 'dart:convert';

Promo promoFromJson(String str) => Promo.fromJson(json.decode(str));

String promoToJson(Promo data) => json.encode(data.toJson());

class Promo {
    List<PromoElement> promos;

    Promo({
        required this.promos,
    });

    factory Promo.fromJson(Map<String, dynamic> json) => Promo(
        promos: List<PromoElement>.from(json["promos"].map((x) => PromoElement.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "promos": List<dynamic>.from(promos.map((x) => x.toJson())),
    };
}

class PromoElement {
    int id;
    String title;
    String description;
    int amountDiscount;
    String category;
    String categoryDisplay;
    int maxUses;
    DateTime startDate;
    DateTime endDate;
    bool isActive;
    String code;
    String urlDetail;
    String? urlUpdate;
    String? urlDelete;

    PromoElement({
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

    factory PromoElement.fromJson(Map<String, dynamic> json) => PromoElement(
        id: json["id"],
        title: json["title"],
        description: json["description"],
        amountDiscount: json["amount_discount"],
        category: json["category"],
        categoryDisplay: json["category_display"],
        maxUses: json["max_uses"],
        startDate: DateTime.parse(json["start_date"]),
        endDate: DateTime.parse(json["end_date"]),
        isActive: json["is_active"],
        code: json["code"],
        urlDetail: json["url_detail"],
        urlUpdate: json["url_update"],
        urlDelete: json["url_delete"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "amount_discount": amountDiscount,
        "category": category,
        "category_display": categoryDisplay,
        "max_uses": maxUses,
        "start_date": "${startDate.year.toString().padLeft(4, '0')}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}",
        "end_date": "${endDate.year.toString().padLeft(4, '0')}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}",
        "is_active": isActive,
        "code": code,
        "url_detail": urlDetail,
        "url_update": urlUpdate,
        "url_delete": urlDelete,
    };
}
