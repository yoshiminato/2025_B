import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:class_2025_b/models/recipe_model.dart';
import 'package:class_2025_b/services/database_service.dart';
import 'package:class_2025_b/states/home_state.dart';


// 最近のレシピを取得するプロバイダ
final recentRecipesProvider = FutureProvider<List<Recipe>>((ref) async {

  // ホーム画面のコンテンツの切り代わりに応じてプロバイダの状態を再読み込み
  final contentType = ref.watch(homeContentTypeProvider);

  // 検索画面以外ではﾚｼﾋﾟの取得は行わない
  if (contentType != ContentType.search) {
    return Future.value([]);
  }

  debugPrint("=== Recent Recipes Provider Debug ===");
  debugPrint("Fetching recent recipes from Firestore...");

  // DatabaseServiceのインスタンスを取得
  final dbService = DatabaseService();
  
  try {
    final recipes = await dbService.getRecentRecipes();
    return recipes;
  } catch (e) {
    debugPrint("Recent recipes fetch FAILED: $e");
    rethrow;
  }
});