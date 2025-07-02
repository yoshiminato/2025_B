import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:class_2025_b/models/recipe_model.dart';
import 'package:class_2025_b/services/database_service.dart';
import 'package:class_2025_b/states/home_state.dart';


// 最近のレシピを取得するプロバイダ
final recentRecipesProvider = FutureProvider<List<Recipe>>((ref) {

  // ホーム画面のコンテンツの切り代わりに応じてプロバイダの状態を再読み込み
  final contentType = ref.watch(currentContentTypeProvider);

  // 検索画面以外ではﾚｼﾋﾟの取得は行わない
  if (contentType != ContentType.search) {
    return Future.value([]);
  }

  // DatabaseServiceのインスタンスを取得
  final dbService = DatabaseService();
  return dbService.getRecentRecipes();
});