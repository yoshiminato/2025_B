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
import 'package:class_2025_b/states/user_state.dart';
import 'package:class_2025_b/widgets/recipe_filter_widget.dart';


const regenerationLimit = 3;

class GenerateScreen extends HookConsumerWidget {
  const GenerateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    // レシピ生成中かどうかのフラグフック
    final isGenerating = useState(false);

    // レシピ作成者情報をレシピに追加
    final user = ref.watch(userProvider);

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
            Recipe? recipe;

            // レシピ生成を試みる
            try {
              var regenerateCount = 0;

              debugPrint("レシピ生成開始");

              while (regenerateCount < regenerationLimit && (recipe == null)) {
                // レシピ生成関数を呼び出す
                debugPrint("レシピ生成中: 再生成カウント: ${regenerateCount+1}");
                recipe = await functionService.generateRecipe(filter);
                regenerateCount++;
              }

              debugPrint("レシピ生成完了: ${recipe.toString()}");

              if (recipe == null) {
                 throw Exception("レシピ生成に失敗しました");
              }

              regenerateCount = 0; // 再生成カウントをリセット
              String? base64Image;
              
              while (regenerateCount < regenerationLimit && (base64Image == null)) {
                // 画像生成関数を呼び出す
                debugPrint("レシピ画像生成中: 再生成カウント: ${regenerateCount+1}");
                base64Image = await functionService.generateBase64Image(recipe);
                debugPrint("生成された画像のbase64: ${base64Image.toString().substring(0,4)}..."); // 先頭20文字だけ表示
                regenerateCount++;
              }

              // 画像生成に成功した場合はレシピに画像を追加
              recipe.imageBase64 = base64Image;
              
              // レシピに作成者情報を付加
              if(user != null) {
                recipe.userId = user.uid;
              }
               
            } 

            catch (e) {
              debugPrint("レシピ生成に失敗しました: $e");
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("レシピ生成に失敗しました"),
                ),
              );
              // レシピ生成に失敗したら生成中フラグを下げて処理中断
              isGenerating.value = false;
              return;
            }

            // レシピ画像をstorage保存を試みる
            final storageService = StorageService();
            try{
              recipe.imageBase64 ??= "";
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
              // 認証エラーの場合は特別なメッセージを表示
              if (e.toString().contains('認証エラー')) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("認証エラー発生,自動ログアウトしました"),
                  ),
                );
                return;
              }
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