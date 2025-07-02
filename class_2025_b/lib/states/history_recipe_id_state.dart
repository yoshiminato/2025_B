import 'package:class_2025_b/states/recipe_id_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:class_2025_b/services/kv_service.dart';
import 'package:class_2025_b/services/database_service.dart';
import 'package:class_2025_b/models/recipe_model.dart';

const limit = 10;

final historyRecipesProvider = FutureProvider<List<Recipe>>((ref) async {

  final recipeId = ref.watch(recipeIdProvider);

  final kvService = KVService();
  // 既存の履歴IDリストを取得
  List<String> historyRecipeIds = await kvService.getRecipeIdsFromKeyType(KeyType.historyRecipeId);

  // 新しい閲覧IDがnullでなければ履歴リストを更新
  if (recipeId != null && recipeId.isNotEmpty) {

    // すでにリストにあれば削除（なければ何もしない）
    if (historyRecipeIds.contains(recipeId)) {
      historyRecipeIds.remove(recipeId);
    }

    // 先頭に追加
    historyRecipeIds.insert(0, recipeId);

    // 必要なら履歴の最大数を制限（例: 20件まで）
    if (historyRecipeIds.length > limit) {
      historyRecipeIds = historyRecipeIds.sublist(0, 20);
    }

    // 保存
    await kvService.saveRecipeIdsForKeyType(KeyType.historyRecipeId, historyRecipeIds);
  }

  // 履歴IDリストから順にRecipeを取得
  final dbService = DatabaseService();
  final List<Recipe> recipes = [];
  for (final id in historyRecipeIds) {
    final recipe = await dbService.getRecipeById(id);
    if (recipe != null) {
      recipes.add(recipe);
    }
  }
  return recipes;
});
