import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:class_2025_b/states/recipe_id_state.dart';
import 'package:class_2025_b/widgets/comment_widget.dart';
import 'package:class_2025_b/widgets/favorite_button_widget.dart';
import 'package:class_2025_b/widgets/recipe_widget.dart';
import 'package:class_2025_b/widgets/review_widget.dart';
import 'package:class_2025_b/widgets/recipe_result_widget.dart';

class RecipeScreen extends ConsumerWidget {
  
  const RecipeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    // レシピIDをプロバイダから取得
    final recipeId = ref.watch(recipeIdProvider);

    // レシピIDがnullの場合の表示
    if (recipeId == null) {
      return const Center(child: Text("レシピが選択されていません"));
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        children: [
          // RecipeWidget(),
          RecipeResultWidget(),
          const SizedBox(height: 20),
          FavoriteButtonWidget(),
          const SizedBox(height: 20),
          ReviewWidget(),
          const SizedBox(height: 20),
          CommentsWidget()
        ],
      )    
    );   
  }
    
}