import 'package:shared_preferences/shared_preferences.dart';

const String favoriteRecipeIdKey = 'favorite_recipe_ids';

enum KeyType {
  favoriteRecipeId('favorite_recipe_ids'),
  historyRecipeId('history_recipe_ids');

  final String value;
  const KeyType(this.value);
}

class KVService {

  Future<void> addRecipeId(KeyType keyType, String value) async {

    final String key = keyType.value;

    final prefs = await SharedPreferences.getInstance();

    final List<String> list = prefs.getStringList(key) ?? [];

    list.add(value);

    await prefs.setStringList(key, list);
  }

  Future<void> removeRecipeId(KeyType keyType, String value) async {

    final String key = keyType.value;

    final prefs = await SharedPreferences.getInstance();

    final List<String> list = prefs.getStringList(key) ?? [];

    list.remove(value);

    await prefs.setStringList(key, list);
  }

  
  Future<List<String>> getRecipeIdsFromKeyType(KeyType keyType) async {

    final String key = keyType.value;

    final prefs = await SharedPreferences.getInstance();
    
    return prefs.getStringList(key) ?? [];
  }

  Future<void> saveRecipeIdsForKeyType(KeyType keyType, List<String> list) async {

    final String key = keyType.value;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setStringList(key, list);
  }

}
