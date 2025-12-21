class Comment {
  final String user;
  final String content;
  final String createdAt;

  Comment({
    required this.user,
    required this.content,
    required this.createdAt,
  });

  // Factory untuk mengubah JSON (Map) menjadi object Comment
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      // 'user' sesuai dengan key di views.py Django kamu
      user: json['user'], 
      
      // 'content' sesuai dengan key di views.py
      content: json['content'], 
      
      // 'created_at' di JSON Django -> diubah jadi 'createdAt' di Dart
      createdAt: json['created_at'], 
    );
  }
}