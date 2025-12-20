// To parse this JSON data, do
//
//     final promoEntry = promoEntryFromJson(jsonString);

import 'dart:convert';

PromoEntry promoEntryFromJson(String str) => PromoEntry.fromJson(json.decode(str));

String promoEntryToJson(PromoEntry data) => json.encode(data.toJson());

class PromoEntry {
    List<Promo> promos;

    PromoEntry({
        required this.promos,
    });

    factory PromoEntry.fromJson(Map<String, dynamic> json) => PromoEntry(
        promos: List<Promo>.from(json["promos"].map((x) => Promo.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "promos": List<dynamic>.from(promos.map((x) => x.toJson())),
    };
}

class Promo {
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
    String urlUpdate;
    String urlDelete;

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

    factory Promo.fromJson(Map<String, dynamic> json) => Promo(
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
