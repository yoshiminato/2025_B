import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:class_2025_b/models/stock_item_model.dart';
import 'package:class_2025_b/services/kv_service.dart';

// @riverpod
// class StockItemNotifier extends _$StockItemNotifier {
//   @override
//   List<StockItem> build() {
//     return [];
//   }
  
//   Future<List<StockItem>> getStockItems() async {

//     final kvService = KVService();

//     final itemName = 
//     return state;
//   }
// }

Future<List<StockItem>> getStockItems() async {
  final kvService = KVService();
  final itemNames = await kvService.getValuesFromKeyType(KeyType.stockitemnameId);
  final itemCounts = await kvService.getValuesFromKeyType(KeyType.stockitemcountId);
  final itemExpiries = await kvService.getValuesFromKeyType(KeyType.stockitemexpiryId);

  // 各リストの長さが一致していることを確認
  if (itemNames.length != itemCounts.length || itemNames.length != itemExpiries.length) {
    throw Exception('Stock item data is inconsistent');
  }

  // StockItemのリストを作成
  final items = List.generate(itemNames.length, (index) {
    return StockItem(
      name: itemNames[index],
      count: int.parse(itemCounts[index]),    
      expiry: itemExpiries[index],
    );
  });
  
  // StockItemのリストに変換
  return items;
}