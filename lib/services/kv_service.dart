import 'package:shared_preferences/shared_preferences.dart';

/// キータイプを定義
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

/// キーと値のペアを管理するサービス
class KVService {

  /// キータイプに対応する値を追加
  Future<void> addValueForKeyType(KeyType keyType, String value) async {
    final String key = keyType.value;
    final prefs = await SharedPreferences.getInstance();
    final List<String> list = prefs.getStringList(key) ?? [];
    list.add(value);
    await prefs.setStringList(key, list);
  }

  /// キータイプに対応する値を削除
  Future<void> removeValueFromKeyType(KeyType keyType, String value) async {
    final String key = keyType.value;
    final prefs = await SharedPreferences.getInstance();
    final List<String> list = prefs.getStringList(key) ?? [];
    list.remove(value);
    await prefs.setStringList(key, list);
  }

  /// キータイプに対応する値をインデックスで削除
  Future<void> removeValueFromKeyTypeByIndex(KeyType keyType, int index) async {
    final String key = keyType.value;
    final prefs = await SharedPreferences.getInstance();
    final List<String> list = prefs.getStringList(key) ?? [];
    if(index < 0 || index >= list.length) return; // インデックスが無効な場合は何もしない
    list.removeAt(index);
    await prefs.setStringList(key, list);
  }

  /// キータイプに対応する値を変更
  Future<void> modifyValueFromKeyTypeByIndex(KeyType keyType, int index, String newValue) async {
    final String key = keyType.value;
    final prefs = await SharedPreferences.getInstance();
    final List<String> list = prefs.getStringList(key) ?? [];
    if(index < 0 || index >= list.length) return; // インデックスが無効な場合は何もしない
    list[index] = newValue;
    await prefs.setStringList(key, list);
  }

  /// キータイプに対応する値のリストを取得
  Future<List<String>> getValuesFromKeyType(KeyType keyType) async {
    final String key = keyType.value;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(key) ?? [];
  }

  /// キータイプに対応する値のリストを保存
  Future<void> saveValuesForKeyType(KeyType keyType, List<String> list) async {
    final String key = keyType.value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(key, list);
  }

  /// キータイプに対応する値を保存
  Future<void> saveValueForKeyType(KeyType keyType, String value) async {
    final String key = keyType.value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  /// キータイプに対応する値を取得
  Future<String> getValueFromKeyType(KeyType keyType) async {
    final String key = keyType.value;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key) ?? '';
  }
}
