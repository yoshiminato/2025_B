class Review {
  final int tasteRating;
  final int easeRating;
  final int cospRating;
  final int uniquenessRating;
  final String recipeId; // レビュー対象のレシピID
  final String userId; // レビューを投稿したユーザーID

  Review({
    required this.tasteRating,
    required this.easeRating,
    required this.cospRating,
    required this.uniquenessRating,
    this.recipeId = '', // レビュー対象のレシピID
    this.userId = '', // レビューを投稿したユーザーID
  });

  // Firestore保存用Map変換
  Map<String, dynamic> toMap(String userId, String recipeId) {
    return {
      'userId': userId,
      'recipeId': recipeId,
      'tasteRating': tasteRating,
      'easeRating': easeRating,
      'cospRating': cospRating,
      'uniquenessRating': uniquenessRating, // 追加: ユニークさの評価
    };
  }

  // Firestoreからの復元
  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      tasteRating: map['tasteRating'] ?? 0,
      easeRating: map['easeRating'] ?? 0,
      cospRating: map['cospRating'] ?? 0,
      uniquenessRating: map['uniquenessRating'] ?? 0,
      recipeId: map['recipeId'] ?? '', // レビュー対象のレシピID
      userId: map['userId'] ?? '', // レビューを投稿したユーザーID
    );
  }

  static get empty => Review(
    tasteRating: 0,
    easeRating: 0,
    cospRating: 0,
    uniquenessRating: 0,
  );

}

class ReviewAverage {
  final double tasteAve;
  final double easeAve;
  final double cospAve;
  final double uniquenessAve;
  final double reccommend;

  ReviewAverage({
    required this.tasteAve, // 味の平均評価
    required this.easeAve, // 簡単さの平均評価
    required this.cospAve, // コストパフォーマンスの平均評価
    required this.uniquenessAve, // ユニークさの平均評価
    required this.reccommend, // 追加: おすすめ度の平均
  });

  static get empty => ReviewAverage(
    tasteAve: 0.0, // 味の初期値
    easeAve: 0.0, // 簡単さの初期値
    cospAve: 0.0, // コストパフォーマンスの初期値
    uniquenessAve: 0.0, // ユニークさの初期値
    reccommend: 0.0, // おすすめ度の初期値
  );
}