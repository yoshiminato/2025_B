import 'package:class_2025_b/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:class_2025_b/models/recipe_model.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:class_2025_b/states/recipe_id_state.dart';
import 'package:class_2025_b/widgets/comment_widget.dart';

class RecipeWidget extends ConsumerWidget {
  // final String? recipeId;
  
  const RecipeWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final recipeId = ref.watch(recipeIdProvider);
    if (recipeId == null) {
      return const Center(child: Text("ﾚｼﾋﾟが選択されていません"));
    }

    // DBからデータ取得
    final dbService = DatabaseService();
    late final Future<Recipe?> futureRecipe;

    try{
      futureRecipe = dbService.getRecipeById(recipeId);
    }
    catch (e) {
      debugPrint("RecipeWidget: DBからのデータ取得に失敗: $e");
      return Center(child: Text("DBからのデータ取得に失敗しました: $e"));
    }

    // FutureBuilderを使用して非同期データを扱う
    final futureBuilder = FutureBuilder<Recipe?>(
      
      // 非同期データ: futureRecipe
      future: futureRecipe,

      // 非同期データの状態に合わせて描画するウィジェットを分岐
      builder: (context, snapshot) {

        // データ取得中ならインジケータを表示
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } 

        // エラーが発生した場合はエラーメッセージを表示
        else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } 

        // データが存在しない場合はメッセージを表示
        else if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text("ﾚｼﾋﾟが見つかりませんでした"));
        } 

        // データが存在する場合はレシピの詳細を表示
        else {
          final recipe = snapshot.data!; 
        
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start, // 左寄せに変更
            children: [
              recipe.imageUrl == null
              ? 
              const Center(child: Text("画像がありません"))
              :
              SizedBox(
                child: 
                recipe.imageUrl == null ?
                Image.asset(
                  "assets/images/no_image.png", 
                  fit: BoxFit.cover, 
                  width: double.infinity):
                Image.network(
                  recipe.imageUrl!,
                  fit: BoxFit.cover,
                  width: double.infinity, // 横幅いっぱいに広げる
                )
              ),
              const SizedBox(height: 20), 
              Center(
                child: Text(recipe.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 20),
              Text(recipe.description, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              Text("調理時間: ${recipe.time}", style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              Text("予算: ${recipe.cost}", style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              Text("材料", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ...recipe.ingredients.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(left: 16.0, bottom: 4.0),
                  child: Text("• ${entry.key}: ${entry.value}", style: const TextStyle(fontSize: 16)),
                );
              }),
              const SizedBox(height: 20),
              Text("手順", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ...recipe.steps.asMap().entries.map((entry) {
                int index = entry.key;
                String step = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
                  child: Text(
                    "${index + 1}. $step",
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.left,
                  ),
                );
              }),
              const SizedBox(height: 20),
              CommentsWidget(recipeId: recipeId)
              
            ],
          );
        }
      },
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        children: [
          futureBuilder,
        ],
      )    
    );   
  }
    
}