import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

const String favoriteRecipeIdKey = 'favorite_recipe_ids';

enum KeyType {
  favoriteRecipeId('favorite_recipe_ids'),
  historyRecipeId('history_recipe_ids'),
  servings('servings'),
  allergys('allergys'),
  tools('tools'),
  stockitemnameId('stockitemname_ids'),
  stockitemcountId('stockitemcount_ids'),
  stockitemexpiryId('stockitemexpiry_ids')
  ;

  final String value;
  const KeyType(this.value);
}

class KVService {

  Future<void> addValueForKeyType(KeyType keyType, String value) async {

    final String key = keyType.value;

    final prefs = await SharedPreferences.getInstance();

    final List<String> list = prefs.getStringList(key) ?? [];

    list.add(value);

    await prefs.setStringList(key, list);
  }

  Future<void> removeValueFromKeyType(KeyType keyType, String value) async {

    final String key = keyType.value;

    final prefs = await SharedPreferences.getInstance();

    final List<String> list = prefs.getStringList(key) ?? [];

    list.remove(value);

    await prefs.setStringList(key, list);
  }

  Future<void> removeValueFromKeyTypeByIndex(KeyType keyType, int index) async {

    final String key = keyType.value;

    final prefs = await SharedPreferences.getInstance();

    final List<String> list = prefs.getStringList(key) ?? [];

    if(index < 0 || index >= list.length) return; // インデックスが無効な場合は何もしない

    // 要素の削除
    list.removeAt(index);

    // 削除の適用
    await prefs.setStringList(key, list);
    
  }

  Future<void> modifyValueFromKeyTypeByIndex(KeyType keyType, int index, String newValue) async {

    final String key = keyType.value;

    final prefs = await SharedPreferences.getInstance();

    final List<String> list = prefs.getStringList(key) ?? [];

    if(index < 0 || index >= list.length) return; // インデックスが無効な場合は何もしない

    // 要素の変更
    list[index] = newValue;

    // 変更の適用
    await prefs.setStringList(key, list);
  }

  

  
  Future<List<String>> getValuesFromKeyType(KeyType keyType) async {

    final String key = keyType.value;

    final prefs = await SharedPreferences.getInstance();
    
    return prefs.getStringList(key) ?? [];
  }

  Future<void> saveValuesForKeyType(KeyType keyType, List<String> list) async {

    final String key = keyType.value;

    final prefs = await SharedPreferences.getInstance();

    debugPrint('Saving values for key: $key, values: $list');

    await prefs.setStringList(key, list);
  }

  Future<void> saveValueForKeyType(KeyType keyType, String value) async {
    final String key = keyType.value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<String> getValueFromKeyType(KeyType keyType) async {
    final String key = keyType.value;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key) ?? '';
  }
}
