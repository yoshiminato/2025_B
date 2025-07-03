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
  Future<void> addValueForKeyType(String recipeId) async {
    final kvService = KVService();
    await kvService.addValueForKeyType(KeyType.favoriteRecipeId, recipeId);
    final List<String> favoriteRecipeIds = await kvService.getValuesFromKeyType(KeyType.favoriteRecipeId);
    state = AsyncData(favoriteRecipeIds);
  }

  // レシピIDを消去するメソッド
  Future<void> removeValueFromKeyType(String recipeId) async {
    final kvService = KVService();
    await kvService.removeValueFromKeyType(KeyType.favoriteRecipeId, recipeId);
    final List<String> favoriteRecipeIds = await kvService.getValuesFromKeyType(KeyType.favoriteRecipeId);
    state = AsyncData(favoriteRecipeIds);
  }
}