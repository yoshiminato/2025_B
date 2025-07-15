import "package:hooks_riverpod/hooks_riverpod.dart";
import 'package:class_2025_b/models/recipe_model.dart';
import 'package:class_2025_b/services/database_service.dart';
import 'package:class_2025_b/states/search_sort_state.dart';

// 検索文字列を保持するプロバイダ
final searchTextProvider = StateProvider<String>((ref) {
  // 初期状態では空文字列
  return "";
});

// 検索結果の有無を保持するプロバイダ
final hasSearchResultProvider = StateProvider<bool>((ref) {
  // 初期状態では検索結果はない
  return false;
});

final searchTriggerProvider = StateProvider<int>((ref) {
  // 検索トリガーの初期状態はfalse
  return 0;
});

final searchResultProvider = FutureProvider<List<Recipe>>((ref) async {

  ref.watch(searchTriggerProvider);

  // 検索結果を取得
  final sortType = ref.watch(sortStateProvider);
  
  // 検索文字列を取得
  final searchText = ref.read(searchTextProvider);
    
  // DatabaseServiceのインスタンスを取得
  final dbService = DatabaseService();
  // dbから検索
  final searchResult = await dbService.getKeywordRecipes(searchText, sortType);

  return searchResult;
});





