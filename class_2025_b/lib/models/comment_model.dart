class Comment{
  final String? id;
  final String recipeId;
  final String userId;
  final String content;
  final DateTime timestamp;
  final String? imageUrl;

  Comment({
    required this.id,
    required this.recipeId,
    required this.userId,
    required this.content,
    required this.timestamp,
    required this.imageUrl,
  });
  // Map形式に変換するメソッド
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'recipeId': recipeId,
      'userId': userId,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'imageUrl': imageUrl,
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
      imageUrl: map['imageUrl'] as String?,
    );
  }
}