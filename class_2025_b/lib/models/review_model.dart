class Review {
  final int tasteRating;
  final int easeRating;
  final int costRating;
  final int uniquenessRating;

  Review({
    required this.tasteRating,
    required this.easeRating,
    required this.costRating,
    required this.uniquenessRating
  });

  // Firestore保存用Map変換
  Map<String, dynamic> toMap(String userId, String recipeId) {
    return {
      'userId': userId,
      'recipeId': recipeId,
      'tasteRating': tasteRating,
      'easeRating': easeRating,
      'costRating': costRating,
      'uniquenessRating': uniquenessRating, // 追加: ユニークさの評価
    };
  }

  // Firestoreからの復元
  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      tasteRating: map['tasteRating'] ?? 0,
      easeRating: map['easeRating'] ?? 0,
      costRating: map['costRating'] ?? 0,
      uniquenessRating: map['uniquenessRating'] ?? 0,
    );
  }

  static get empty => Review(
    tasteRating: 0,
    easeRating: 0,
    costRating: 0,
    uniquenessRating: 0,
  );

}