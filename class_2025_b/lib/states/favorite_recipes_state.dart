import 'package:class_2025_b/services/database_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:class_2025_b/states/favorite_recipe_id_state.dart';
import 'package:class_2025_b/states/home_state.dart';
import 'package:class_2025_b/models/recipe_model.dart';


final favoriteRecipesProvider = FutureProvider<List<Recipe>>((ref)  async{

  final contentType = ref.watch(currentContentTypeProvider);

  // 検索画面以外ではﾚｼﾋﾟの取得は行わない
  if (contentType != ContentType.search) {
    return Future.value([]);
  }

  // お気に入りレシピが更新されるたびにプロバイダの状態更新
  final favoriteRecipeIds = await ref.watch(favoriteRecipeIdNotifierProvider.future);

  // DatabaseServiceのインスタンスを作成
  final dbService = DatabaseService();

  // ﾚｼﾋﾟリスト
  final List<Recipe> favoriteRecipes = [];

  for (final recipeId in favoriteRecipeIds) {
    // ﾚｼﾋﾟIDからﾚｼﾋﾟを取得
    try {
      final recipe = await dbService.getRecipeById(recipeId);
      if (recipe != null) {
        favoriteRecipes.add(recipe);
      }
    }
    // エラーはウィジェット側で任せる 
    catch (e) {
      rethrow;
    }
  }
  
  return favoriteRecipes;
});