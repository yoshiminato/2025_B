import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:class_2025_b/models/stock_item_model.dart';
import 'package:class_2025_b/services/kv_service.dart';
import 'package:flutter/foundation.dart';


Future<List<StockItem>> getStockItems() async {
  final kvService = KVService();
  final itemNames = await kvService.getValuesFromKeyType(KeyType.stockitemnameId);
  final itemCounts = await kvService.getValuesFromKeyType(KeyType.stockitemcountId);
  final itemExpiries = await kvService.getValuesFromKeyType(KeyType.stockitemexpiryId);

  // StockItemのリストを作成
  final items = List.generate(itemNames.length, (index) {
    // 安全にint.parseを実行
    int? count;
    try {
      count = int.parse(itemCounts[index]);
    } 
    catch (e) {
      count = null;
    }
    // 食糧情報を返す
    return StockItem(
      name: itemNames[index],
      count: count,    
      expiry: itemExpiries[index],
    );
  });

  // 食糧庫の情報を返却
  return items;
}