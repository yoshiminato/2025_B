import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:class_2025_b/services/kv_service.dart';
part 'favorite_recipe_id_state.g.dart';

@riverpod
class FavoriteRecipeIdNotifier extends _$FavoriteRecipeIdNotifier {
  @override
  Future<List<String>> build() async {
    final kvService = KVService();
    return kvService.getRecipeIdsFromKeyType(KeyType.favoriteRecipeId);
  }

  // レシピIDを設定するメソッド
  Future<void> addRecipeId(String recipeId) async {
    final kvService = KVService();
    await kvService.addRecipeId(KeyType.favoriteRecipeId, recipeId);
    final List<String> favoriteRecipeIds = await kvService.getRecipeIdsFromKeyType(KeyType.favoriteRecipeId);
    state = AsyncData(favoriteRecipeIds);
  }

  // レシピIDを消去するメソッド
  Future<void> removeRecipeId(String recipeId) async {
    final kvService = KVService();
    await kvService.removeRecipeId(KeyType.favoriteRecipeId, recipeId);
    final List<String> favoriteRecipeIds = await kvService.getRecipeIdsFromKeyType(KeyType.favoriteRecipeId);
    state = AsyncData(favoriteRecipeIds);
  }
}