import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:class_2025_b/models/stock_item_model.dart';
import 'package:class_2025_b/services/kv_service.dart';
import 'package:flutter/foundation.dart';


Future<List<StockItem>> getStockItems() async {
  final kvService = KVService();
  final itemNames = await kvService.getValuesFromKeyType(KeyType.stockitemnameId);
  final itemCounts = await kvService.getValuesFromKeyType(KeyType.stockitemcountId);
  final itemExpiries = await kvService.getValuesFromKeyType(KeyType.stockitemexpiryId);

  // デバッグ出力
  debugPrint('Stock item names: $itemNames');
  debugPrint('Stock item counts: $itemCounts');
  debugPrint('Stock item expiries: $itemExpiries');

  // 各リストの長さが一致していることを確認
  if (itemNames.length != itemCounts.length || itemNames.length != itemExpiries.length) {
    debugPrint('ERROR: Stock item data is inconsistent - names: ${itemNames.length}, counts: ${itemCounts.length}, expiries: ${itemExpiries.length}');
    throw Exception('Stock item data is inconsistent');
  }

  // StockItemのリストを作成
  final items = List.generate(itemNames.length, (index) {
    // 安全にint.parseを実行
    int? count;
    try {
      count = int.parse(itemCounts[index]);
    } catch (e) {
      count = null;
    }
    
    return StockItem(
      name: itemNames[index],
      count: count,    
      expiry: itemExpiries[index],
    );
  });

  
  // StockItemのリストに変換
  return items;
}