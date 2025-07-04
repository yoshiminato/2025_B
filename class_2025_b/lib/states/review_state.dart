import 'package:class_2025_b/states/user_state.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:class_2025_b/services/database_service.dart';
import 'package:class_2025_b/models/review_model.dart';
import 'package:class_2025_b/states/recipe_id_state.dart';


// レビューが投稿されるごとに発火するプロバイダ
final reviewTriggerProvider = StateProvider<int>((ref) {
  // レビューのトリガー状態を管理
  return 0;
});

// レビューの状態を管理するプロバイダ
final reviewProvider = FutureProvider<Review>((ref) async {

  final recipeId = ref.watch(recipeIdProvider); // レシピIDを監視して再構築を促す

  final dbService = DatabaseService();

  if(recipeId == null || recipeId.isEmpty) {
    debugPrint('Recipe ID is null or empty, returning empty review');
    return Review.empty; // レシピIDが無い場合は空のレビューを返す
  }

  final user = ref.watch(userProvider);
  if (user == null) {
    return Review.empty;
  }

  final userId = user.uid;


  if (recipeId == null || recipeId.isEmpty) {
    throw Exception('Recipe ID is null or empty');
  }

  // レビューをデータベースから取得
  final Review review = await dbService.getReviewByRecipeIdAndUserId(userId, recipeId);

  debugPrint('Fetched review: $review for user $userId and recipe $recipeId');

  return review;
});

Future<void> addReview(int tRating, int eRating, int cRating, int uRating, WidgetRef ref) async {

  final user = ref.read(userProvider);

  // ユーザーがログインしているか確認
  if (user == null) {
    throw Exception('ログインしていません');
  }

  final userId = user.uid;

  final recipeId = ref.read(recipeIdProvider);

  if (recipeId == null || recipeId.isEmpty) {
    throw Exception('レシピIDが取得できていません');
  }

  // DBサービスのインスタンスを作成
  final dbService = DatabaseService();

  // reviewインスタンスの作成
  final review = Review(
    tasteRating: tRating,
    easeRating: eRating,
    costRating: cRating,
    uniquenessRating: uRating,
  );

  // レビューをデータベースに追加
  await dbService.addReview(userId, recipeId, review);

  return;
}