import "package:hooks_riverpod/hooks_riverpod.dart";
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:class_2025_b/models/recipe_model.dart';
import 'package:class_2025_b/services/database_service.dart';
part 'search_state.g.dart';

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


@Riverpod(keepAlive: true)
class SearchResultNotifier extends _$SearchResultNotifier {

  @override
  Future<List<Recipe>> build() async {
    
    // 初期状態では空のリストを返す
    return [];
  }

  // 検索結果を更新するメソッド
  Future<void> updateSearchResult() async {
    
    // DatabaseServiceのインスタンスを取得
    final dbService = DatabaseService();

    // 検索文字列を取得
    final searchText = ref.read(searchTextProvider);

    // dbから検索
    final searchResult = await dbService.getKeywordRecipes(searchText);

    // 検索結果を更新
    state = AsyncData(searchResult);
  }

  clearSearchResult() {
    // 検索結果を空にする
    state = const AsyncData([]);
  }
}



