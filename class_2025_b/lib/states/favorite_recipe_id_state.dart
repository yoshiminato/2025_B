import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:class_2025_b/services/kv_service.dart';
part 'favorite_recipe_id_state.g.dart';

@riverpod
class FavoriteRecipeIdNotifier extends _$FavoriteRecipeIdNotifier {
  @override
  Future<List<String>> build() async {
    final kvService = KVService();
    return kvService.getFavoriteRecipeIds();
  }

  // レシピIDを設定するメソッド
  Future<void> addRecipeId(String recipeId) async {
    final kvService = KVService();
    await kvService.addFavoriteRecipeId(recipeId);
    final List<String> favoriteRecipeIds = await kvService.getFavoriteRecipeIds();
    state = AsyncData(favoriteRecipeIds);
  }

  // レシピIDを消去するメソッド
  Future<void> removeRecipeId(String recipeId) async {
    final kvService = KVService();
    await kvService.removeFavoriteRecipeId(recipeId);
    final List<String> favoriteRecipeIds = await kvService.getFavoriteRecipeIds();
    state = AsyncData(favoriteRecipeIds);
  }
}