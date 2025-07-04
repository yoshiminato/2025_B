import 'package:class_2025_b/models/filter_model.dart';
import 'package:class_2025_b/services/database_service.dart';
import 'package:class_2025_b/services/storage_service.dart';
import 'package:class_2025_b/states/custom_state.dart';
import 'package:class_2025_b/states/home_state.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:class_2025_b/services/function_service.dart';
import 'package:class_2025_b/models/recipe_model.dart';
import 'package:class_2025_b/states/recipe_id_state.dart';
import 'package:class_2025_b/states/user_state.dart';
import 'package:class_2025_b/widgets/recipe_filter_widget.dart';
import 'package:class_2025_b/services/kv_service.dart';


const regenerationLimit = 3;

class GenerateScreen extends HookConsumerWidget {
  const GenerateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // --- アレルギー情報をKVからリセットする関数 ---

    // レシピ生成中かどうかのフラグフック
    final isGenerating = useState(false);

    // レシピ作成者情報をレシピに追加
    final user = ref.watch(userProvider);

    final usePantryOnly = useState(false);
    final buttonLabels = [
      '濃厚な', 'スパイシー', 'ジューシー',
      'さっぱり', 'こってり', '淡泊な',
      'クセになる', 'うま味', 'まろやか',
      'コク深い', '香ばしい', '素朴な',
    ];

    final asyncCustomize = ref.watch(customizeNotifierProvider);

    debugPrint("状態: ${asyncCustomize.toString()}");
 

    final buttonStates = useState(List<bool>.filled(12, false));
    final budgetValue = useState(500.0);
    final timeValue = useState(30.0);
    final searchKeyword = useState('');
    final servingsState = useState(1.0);

    useEffect((){
      if (asyncCustomize is AsyncData && asyncCustomize.value != null) {
        servingsState.value = asyncCustomize.value!.servings.toDouble();
      }
      // 依存配列にasyncCustomizeを入れることで、値が変わったときだけ反映
      return null;
    }, [asyncCustomize]);

    void resetFilters() {
      buttonStates.value = List<bool>.filled(12, false);
      budgetValue.value = 500;
      timeValue.value = 30;
      servingsState.value = 1;
      searchKeyword.value = '';
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 追加: 食糧庫のみ使用チェックボックス
          Row(
            children: [
              Checkbox(
                value: usePantryOnly.value,
                onChanged: (val) {
                  if (val != null) usePantryOnly.value = val;
                },
              ),
              const Text('食糧庫の食材のみを使用'),
              const SizedBox(width: 8),
            ],
          ),
          usePantryOnly.value
            ? SizedBox.shrink()
            : Column(
              children: [
                SizedBox(
                  height: 35,
                  child: TextField(
                    onChanged: (value) => searchKeyword.value = value,
                    style: const TextStyle(fontSize: 12),
                    decoration: InputDecoration(
                      hintText: '使用する食材をスペース区切りで入力',
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(left: 8, right: 4, top: 2, bottom: 2),
                        child: Icon(Icons.search, size: 16),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 2.5,
            children: List.generate(buttonLabels.length, (index) {
              final state = buttonStates.value[index];
              final color = state
                  ? Colors.red
                  : Colors.grey.shade300;
              final textColor = state ? Colors.white : Colors.black;

              return ElevatedButton(
                onPressed: () {
                  final newStates = List<bool>.from(buttonStates.value);
                  newStates[index] = !newStates[index];
                  buttonStates.value = newStates;
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  shape: const StadiumBorder(),
                ),
                child: Text(
                  buttonLabels[index],
                  style: TextStyle(color: textColor, fontSize: 10, overflow: TextOverflow.ellipsis),
                ),
              );
            }),
          ),
          const SizedBox(height: 32),
          Text("予算: ${budgetValue.value.toInt()} 円"),
          Slider(
            value: budgetValue.value,
            min: 0,
            max: 1500,
            divisions: 100,
            label: '${budgetValue.value.toInt()} 円',
            activeColor: Colors.orange,
            inactiveColor: Colors.orange.shade100,
            onChanged: (value) => budgetValue.value = value,
          ),
          Text("調理時間: ${timeValue.value.toInt()} 分"),
          Slider(
            value: timeValue.value,
            min: 0,
            max: 90,
            divisions: 10,
            label: '${timeValue.value.toInt()} 分',
            activeColor: Colors.orange,
            inactiveColor: Colors.orange.shade100,
            onChanged: (value) => timeValue.value = value,
          ),
          Text("分量: ${servingsState.value.toInt()} 人前"),
          Slider(
            value: servingsState.value.toDouble(),
            min: 1,
            max: 10,
            divisions: 5,
            label: '${servingsState.value.toInt()} 人前',
            activeColor: Colors.orange,
            inactiveColor: Colors.orange.shade100,
            onChanged: (value) => servingsState.value = value,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: resetFilters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("リセット"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    // レシピ生成中のフラグをたてる
                    isGenerating.value = true;

                    // レシピ生成処理
                    final functionService = FunctionService();

                    List<String> ingredients = searchKeyword.value
                      .split(RegExp(r'\s+')) // 半角・全角スペース、タブなどすべての空白で分割
                      .map((keyword) => keyword.trim().toLowerCase())
                      .where((keyword) => keyword.isNotEmpty)
                      .toList();

                    final asyncCustomize = ref.read(customizeNotifierProvider);

                    late final List<String> allergys;
                    late final List<String> availableTools;
                    if (asyncCustomize.value != null) {
                      // カスタマイズ設定がある場合は分量を上書き
                      allergys = asyncCustomize.value!.allergys;
                      availableTools = asyncCustomize.value!.availableTools;
                    }

                    // サンプルフィルターを使用(開発段階では固定値を使用)
                    // 後でユーザーが入力した値を使用するように変更する
                    final Filter filter = Filter(
                      usePantryOnly: usePantryOnly.value,
                      ingredients: ingredients,
                      attributes: buttonStates.value.asMap().entries
                        .where((entry) => entry.value)
                        .map((entry) => buttonLabels[entry.key])
                        .toList(),
                      budget: budgetValue.value.toInt(),
                      time: timeValue.value.toInt(),
                      servings: servingsState.value.toInt(),
                      allergy: allergys,
                      availableTools: availableTools
                    );

                    // 生成されたレシピを格納する変数
                    Recipe? recipe;

                    // debugPrint("食糧庫参照: ${filter.usePantryOnly.toString()}");
                    // debugPrint("材料: ${filter.ingredients.toString()}");
                    // debugPrint("気分: ${filter.attributes.toString()}");
                    // debugPrint("予算: ${filter.budget.toString()}");
                    // debugPrint("調理時間: ${filter.time.toString()}");
                    // debugPrint("分量: ${filter.servings.toString()}");
                    // debugPrint("アレルギー: ${filter.allergy.toString()}");
                    // debugPrint("使用可能な調理器具: ${filter.availableTools.toString()}");

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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("開始"),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    // final column = Column(
    //   mainAxisAlignment: MainAxisAlignment.center,
    //   children: [
    //     RecipeFilterWidget(),
    //     isGenerating.value
    //     ? 
    //     // レシピ生成中はインジケータ表示
    //     const CircularProgressIndicator()
    //     :
    //     // レシピ生成中でなければ生成ボタン表示
    //     ElevatedButton(
    //       //生成ボタンが押された場合の処理
    //       onPressed: () async {

    //         // レシピ生成中のフラグをたてる
    //         isGenerating.value = true;

    //         // レシピ生成処理
    //         final functionService = FunctionService();

    //         // サンプルフィルターを使用(開発段階では固定値を使用)
    //         // 後でユーザーが入力した値を使用するように変更する
    //         final Filter filter = sampleFilter;

    //         // 生成されたレシピを格納する変数
    //         Recipe? recipe;

    //         // レシピ生成を試みる
    //         try {
    //           var regenerateCount = 0;

    //           debugPrint("レシピ生成開始");

    //           while (regenerateCount < regenerationLimit && (recipe == null)) {
    //             // レシピ生成関数を呼び出す
    //             debugPrint("レシピ生成中: 再生成カウント: ${regenerateCount+1}");
    //             recipe = await functionService.generateRecipe(filter);
    //             regenerateCount++;
    //           }

    //           debugPrint("レシピ生成完了: ${recipe.toString()}");

    //           if (recipe == null) {
    //              throw Exception("レシピ生成に失敗しました");
    //           }

    //           regenerateCount = 0; // 再生成カウントをリセット
    //           String? base64Image;
              
    //           while (regenerateCount < regenerationLimit && (base64Image == null)) {
    //             // 画像生成関数を呼び出す
    //             debugPrint("レシピ画像生成中: 再生成カウント: ${regenerateCount+1}");
    //             base64Image = await functionService.generateBase64Image(recipe);
    //             debugPrint("生成された画像のbase64: ${base64Image.toString().substring(0,4)}..."); // 先頭20文字だけ表示
    //             regenerateCount++;
    //           }

    //           // 画像生成に成功した場合はレシピに画像を追加
    //           recipe.imageBase64 = base64Image;
              
    //           // レシピに作成者情報を付加
    //           if(user != null) {
    //             recipe.userId = user.uid;
    //           }
               
    //         } 

    //         catch (e) {
    //           debugPrint("レシピ生成に失敗しました: $e");
    //           ScaffoldMessenger.of(context).showSnackBar(
    //             SnackBar(
    //               content: Text("レシピ生成に失敗しました"),
    //             ),
    //           );
    //           // レシピ生成に失敗したら生成中フラグを下げて処理中断
    //           isGenerating.value = false;
    //           return;
    //         }

    //         // レシピ画像をstorage保存を試みる
    //         final storageService = StorageService();
    //         try{
    //           recipe.imageBase64 ??= "";
    //           final base64String = recipe.imageBase64!;

    //           final String? imageUrl = await storageService.storeBase64ImageAndGetUrl(base64String, "recipe");
    //           recipe.imageUrl = imageUrl;
    //         }
    //         catch (e) {
    //           ScaffoldMessenger.of(context).showSnackBar(
    //             SnackBar(
    //               content: Text("レシピ画像の保存に失敗しました: ${e.toString()}"),
    //             ),
    //           );
    //           // 画像保存に失敗したら生成中フラグを下げて処理中断
    //           isGenerating.value = false;
    //           return;
    //         }

    //         // レシピのDB登録を試みる
    //         final dbService = DatabaseService();
    //         try {
    //           final String? recipeId = await dbService.addRecipe(recipe);
    //           if (recipeId == null) {
    //             ScaffoldMessenger.of(context).showSnackBar(
    //               SnackBar(
    //                 content: Text("レシピIDがnullです"),
    //               ),
    //             );
    //           }
              
    //           // レシピIDを状態管理に保存
    //           final recipeIdNotifier = ref.read(recipeIdProvider.notifier);
    //           recipeIdNotifier.state = recipeId;

    //           // レシピの詳細画面に遷移
    //           final contentNotifier = ref.read(currentContentTypeProvider.notifier);
    //           contentNotifier.state = ContentType.recipe;
    //         }
    //         catch (e) {
    //           // 認証エラーの場合は特別なメッセージを表示
    //           if (e.toString().contains('認証エラー')) {
    //             ScaffoldMessenger.of(context).showSnackBar(
    //               SnackBar(
    //                 content: Text("認証エラー発生,自動ログアウトしました"),
    //               ),
    //             );
    //             return;
    //           }
    //           ScaffoldMessenger.of(context).showSnackBar(
    //             SnackBar(
    //               content: Text("レシピの保存に失敗しました: ${e.toString()}"),
    //             ),
    //           );
    //         }
    //         isGenerating.value = false;
    //       },
    //       // ボタン内に表示するテキスト
    //       child: 
    //         const Text("レシピ生成ボタン")
    //     ),
    //   ],
    // );
    // return SingleChildScrollView(
    //   child: Center(
    //     child: column,
    //   )
    // );
  }
}