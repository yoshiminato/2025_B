import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:class_2025_b/services/kv_service.dart';
part 'favorite_recipe_id_state.g.dart';

@riverpod
class FavoriteRecipeIdNotifier extends _$FavoriteRecipeIdNotifier {
  @override
  Future<List<String>> build() async {
    final kvService = KVService();
    return kvService.getValuesFromKeyType(KeyType.favoriteRecipeId);
  }

  // レシピIDを設定するメソッド
  Future<void> addValue(String recipeId) async {
    final kvService = KVService();
    await kvService.addValue(KeyType.favoriteRecipeId, recipeId);
    final List<String> favoriteRecipeIds = await kvService.getValuesFromKeyType(KeyType.favoriteRecipeId);
    state = AsyncData(favoriteRecipeIds);
  }

  // レシピIDを消去するメソッド
  Future<void> removeValue(String recipeId) async {
    final kvService = KVService();
    await kvService.removeValue(KeyType.favoriteRecipeId, recipeId);
    final List<String> favoriteRecipeIds = await kvService.getValuesFromKeyType(KeyType.favoriteRecipeId);
    state = AsyncData(favoriteRecipeIds);
  }
}