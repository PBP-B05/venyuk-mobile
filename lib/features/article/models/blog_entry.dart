import 'dart:convert';

List<BlogEntry> blogEntryFromJson(String str) => List<BlogEntry>.from(json.decode(str).map((x) => BlogEntry.fromJson(x)));

String blogEntryToJson(List<BlogEntry> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class BlogEntry {
    String model;
    int pk;
    Fields fields;

    BlogEntry({
        required this.model,
        required this.pk,
        required this.fields,
    });

    factory BlogEntry.fromJson(Map<String, dynamic> json) => BlogEntry(
        model: json["model"],
        pk: json["pk"],
        fields: Fields.fromJson(json["fields"]),
    );

    Map<String, dynamic> toJson() => {
        "model": model,
        "pk": pk,
        "fields": fields.toJson(),
    };
}

class Fields {
    int? user;
    String title;
    String content;
    String dateAdded;
    int blogViews;
    String category;
    String? contentComment;
    String? thumbnail;

    Fields({
        this.user,
        required this.title,
        required this.content,
        required this.dateAdded,
        required this.blogViews,
        required this.category,
        this.contentComment,
        this.thumbnail,
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        user: json["user"],
        title: json["title"],
        content: json["content"],
        dateAdded: json["date_added"],
        blogViews: json["blog_views"],
        category: json["category"],
        contentComment: json["content_comment"],
        thumbnail: json["thumbnail"],
    );

    Map<String, dynamic> toJson() => {
        "user": user,
        "title": title,
        "content": content,
        "date_added": dateAdded,
        "blog_views": blogViews,
        "category": category,
        "content_comment": contentComment,
        "thumbnail": thumbnail,
    };
}