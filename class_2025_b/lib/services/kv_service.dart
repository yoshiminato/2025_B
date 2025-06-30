import 'package:shared_preferences/shared_preferences.dart';

const String favoriteRecipeIdKey = 'favorite_recipe_ids';

Future<void> addFavoriteRecipeId(String value) async {

  final prefs = await SharedPreferences.getInstance();

  final List<String> favoriteRecipeIds = prefs.getStringList(favoriteRecipeIdKey) ?? [];

  favoriteRecipeIds.add(value);

  await prefs.setStringList(favoriteRecipeIdKey, favoriteRecipeIds);
}


Future<void> removeFavoriteRecipeId(String value) async {
  final prefs = await SharedPreferences.getInstance();
  // 既存リストを取得（なければ空リスト）
  List<String> list = prefs.getStringList(favoriteRecipeIdKey) ?? [];
  // 指定の要素を削除
  list.remove(value);
  // 保存
  await prefs.setStringList(favoriteRecipeIdKey, list);
}

Future<List<String>> getFavoriteRecipeIds() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getStringList(favoriteRecipeIdKey) ?? [];
}