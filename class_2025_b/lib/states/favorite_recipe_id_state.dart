import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:class_2025_b/services/kv_service.dart';
part 'favorite_recipe_id_state.g.dart';

@riverpod
class FavoriteRecipeIdNotifier extends _$FavoriteRecipeIdNotifier {
  @override
  Future<List<String>> build() async {
    return getFavoriteRecipeIds();
  }

  // レシピIDを設定するメソッド
  Future<void> addRecipeId(String recipeId) async {
    await addFavoriteRecipeId(recipeId);
    final List<String> favoriteRecipeIds = await getFavoriteRecipeIds();
    state = AsyncData(favoriteRecipeIds);
  }

  // レシピIDを消去するメソッド
  Future<void> removeRecipeId(String recipeId) async {
    await removeFavoriteRecipeId(recipeId);
    final List<String> favoriteRecipeIds = await getFavoriteRecipeIds();
    state = AsyncData(favoriteRecipeIds);
  }
}