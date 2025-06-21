import 'package:class_2025_b/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:class_2025_b/routers/router.dart';
import 'package:class_2025_b/models/recipe_model.dart';

class RecipeScreen extends StatelessWidget {
  final String? recipeId;
  
  const RecipeScreen({super.key, this.recipeId});

  @override
  Widget build(BuildContext context) {

    // DBからデータ取得
    final dbService = DatabaseService();
    final Future<Recipe?> futureRecipe = dbService.getRecipeById(recipeId!);


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
              // タイトルは中央揃えにしたい場合
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
              
            ],
          );
        }
      },
    );

    // ホームに戻るボタン
    final homeButton = ElevatedButton(
      onPressed: () => AppRouter.goToHome(context),
      child: const Text("ﾎｰﾑに戻る")
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Recipe Details"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: [
            futureBuilder, 
            SizedBox(height: 20),
            homeButton
          ],
        )
      )
    );
    
  }
    
}