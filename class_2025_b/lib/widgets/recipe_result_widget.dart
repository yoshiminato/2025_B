import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:class_2025_b/states/recipe_id_state.dart';

/*レシピ情報*/
class RecipeInfo {
  final String title; //レシピタイトル
  final int number; //何人前
  final String time; //調理時間(分)
  final String cost; //想定予算
  RecipeInfo(this.title, this.number, this.time, this.cost);
}

class RecipeIngredients {
  final String name; //材料名
  final String amount; //分量
  const RecipeIngredients(this.name, this.amount);
}

class RecipeManual {
  final int number; //手順番号
  final String manual; //説明文
  const RecipeManual(this.number, this.manual);
}


class RecipeResultWidget extends ConsumerWidget {

  const RecipeResultWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final asyncRecipe = ref.watch(recipeProvider);

    return asyncRecipe.when(
      data: (recipe) {

        final RecipeInfo rInfo = RecipeInfo(
          recipe.title, 
          recipe.servings, 
          recipe.time, 
          recipe.cost
        );

        final List<RecipeIngredients> rIngredients = recipe.ingredients
          .entries.map((item) => RecipeIngredients(item.key, item.value))
          .toList();

        final List<RecipeManual> rSteps = recipe.steps
          .asMap()
          .entries
          .map((entry) => RecipeManual(entry.key + 1, entry.value))
          .toList();


        return Column(
          children: [
            //レシピタイトル＆概要//想定予算、所要時間
            Text(
              "${rInfo.title}のレシピ",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
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
            const SizedBox(height: 8),
            Text(
              '想定予算：${rInfo.cost}\n所要時間：${rInfo.time}',
              style: TextStyle(fontSize: 15),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            //必要な材料の情報//何人前
            Text(
              '材料(${rInfo.number}人前)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 255, 239, 216),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: rIngredients.map(
                  (ing) => Row(
                    children: [
                      Expanded(
                        child: Text(ing.name, textAlign: TextAlign.center),
                      ),
                      Expanded(
                        child: Text(
                          '　　　' + ing.amount,
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                ).toList(),
              ),
            ),
            const SizedBox(height: 8),
            //レシピ手順書
            Text(
              '手順',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 255, 239, 216),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: rSteps.map(
                  (stp) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            '${stp.number}.',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            stp.manual,
                            style: const TextStyle(fontSize: 15),
                            softWrap: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ).toList(),
              ),
            ),
          ],
        );
      },
      error: (error, stack) {
        return Center(child: Text('Error: $error'));
      },
      loading: () {
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}