import 'package:class_2025_b/models/filter_model.dart';
import 'package:class_2025_b/services/database_service.dart';
import 'package:class_2025_b/services/storage_service.dart';
import 'package:class_2025_b/states/home_state.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:class_2025_b/services/function_service.dart';
import 'package:class_2025_b/models/recipe_model.dart';
import 'package:class_2025_b/states/recipe_id_state.dart';
import 'package:class_2025_b/widgets/recipe_filter_widget.dart';

class GenerateWidget extends HookConsumerWidget {
  const GenerateWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    // レシピ生成中かどうかのフラグフック
    final isGenerating = useState(false);

    final column = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RecipeFilterWidget(),
        isGenerating.value
        ? 
        // レシピ生成中はインジケータ表示
        const CircularProgressIndicator()
        :
        // レシピ生成中でなければ生成ボタン表示
        ElevatedButton(
          //生成ボタンが押された場合の処理
          onPressed: () async {

            // レシピ生成中のフラグをたてる
            isGenerating.value = true;

            // レシピ生成処理
            final functionService = FunctionService();

            // サンプルフィルターを使用(開発段階では固定値を使用)
            // 後でユーザーが入力した値を使用するように変更する
            final Filter filter = sampleFilter;

            // 生成されたレシピを格納する変数
            late final Recipe? recipe;

            // レシピ生成を試みる
            try {
               recipe = await functionService.generateRecipe(filter);
            } 

            catch (e) {
              debugPrint("レシピ生成に失敗: ${e.toString()}");
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("レシピ生成に失敗しました: ${e.toString()}"),
                ),
              );
              // レシピ生成に失敗したら生成中フラグを下げて処理中断
              isGenerating.value = false;
              return;
            }

            // レシピ画像をstorage保存を試みる
            final storageService = StorageService();
            try{
              recipe!.imageBase64 ??= "";
              final base64String = recipe.imageBase64!;

              final String? imageUrl = await storageService.storeBase64ImageAndGetUrl(base64String, "recipe");
              recipe.imageUrl = imageUrl;
            }
            catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("レシピ画像の保存に失敗しました: ${e.toString()}"),
                ),
              );
              // 画像保存に失敗したら生成中フラグを下げて処理中断
              isGenerating.value = false;
              return;
            }

            // レシピのDB登録を試みる
            final dbService = DatabaseService();
            try {
              final String? recipeId = await dbService.addRecipe(recipe);
              if (recipeId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("レシピIDがnullです"),
                  ),
                );
              }
              
              // レシピIDを状態管理に保存
              final recipeIdNotifier = ref.read(recipeIdProvider.notifier);
              recipeIdNotifier.state = recipeId;
              // レシピの詳細画面に遷移
              final contentNotifier = ref.read(currentContentTypeProvider.notifier);
              contentNotifier.state = ContentType.recipe;
            }
            catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("レシピの保存に失敗しました: ${e.toString()}"),
                ),
              );
            }
            isGenerating.value = false;
          },
          // ボタン内に表示するテキスト
          child: 
            const Text("レシピ生成ボタン")
        ),
      ],
    );
    return SingleChildScrollView(
      child: Center(
        child: column,
      )
    );
  }
}