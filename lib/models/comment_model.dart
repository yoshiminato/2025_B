import 'package:class_2025_b/models/review_model.dart';

class Comment{
  final String? id;
  final String recipeId;
  final String? userId;
  final String content;
  Review? review; // レビュー情報（オプション） 
  final DateTime timestamp;
  final String? imagePath; // 画像のパス（ストレージ上のURL）

  Comment({
    required this.id,
    required this.recipeId,
    required this.userId,
    required this.content,
    required this.timestamp,
    required this.imagePath,
  });
  // Map形式に変換するメソッド
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'recipeId': recipeId,
      'userId': userId,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'imagePath': imagePath,
    };
  }

  // MapからCommentオブジェクトを生成するファクトリーメソッド
  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'] ?? '',
      recipeId: map['recipeId'] ?? '',
      userId: map['userId'] ?? '',
      content: map['content'] ?? '',
      timestamp: DateTime.parse(map['timestamp']),
      imagePath: map['imagePath'] as String?,
    );
  }
}