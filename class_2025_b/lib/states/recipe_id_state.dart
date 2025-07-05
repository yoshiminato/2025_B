import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:class_2025_b/services/database_service.dart';
import 'package:class_2025_b/models/recipe_model.dart';

final recipeIdProvider = StateProvider<String?>((ref) {
  return null; // 初期値はnull
});

final recipeProvider = FutureProvider<Recipe>((ref) async {
  final recipeId = ref.watch(recipeIdProvider);

  if (recipeId == null || recipeId.isEmpty) {
    throw Exception('Recipe ID is not set');
  }

  // DatabaseServiceのインスタンスを作成
  final dbService = DatabaseService();

  // レシピIDからレシピを取得
  final recipe = await dbService.getRecipeById(recipeId);

  if (recipe == null) {
    throw Exception('Recipe not found for ID: $recipeId');
  }

  return recipe;
});