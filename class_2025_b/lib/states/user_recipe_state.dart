import 'package:class_2025_b/services/database_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:class_2025_b/states/home_state.dart';
import 'package:class_2025_b/states/user_state.dart';
import 'package:class_2025_b/models/recipe_model.dart';


final usersRecipesProvider = FutureProvider<List<Recipe>>((ref)  async{

  final contentType = ref.watch(currentContentTypeProvider);

  // 検索画面以外ではﾚｼﾋﾟの取得は行わない
  if (contentType != ContentType.search) {
    return Future.value([]);
  }

  // ユーザ情報を取得
  final user = ref.watch(userProvider);
  final userId = (user!=null) ? user.uid : null;

  // ユーザIDがnullの場合は空のリストを返す
  if (userId == null) {
    return Future.value([]);
  }

  // DatabaseServiceのインスタンスを作成
  final dbService = DatabaseService();

  // ユーザの作成したレシピを取得
  final usersRecipes = await dbService.getUsersRecipes(userId);

  return usersRecipes;
});