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
import 'package:class_2025_b/states/generate_state.dart';
import 'package:class_2025_b/models/review_model.dart';
import 'dart:ui';

class GenerateScreen extends HookConsumerWidget {
  const GenerateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // --- アレルギー情報をKVからリセットする関数 ---

    // レシピ生成中かどうかのフラグフック
    final isGenerating = useState(false);

    final genState = ref.watch(generateStateNotifierProvider);
    final notifier = ref.read(generateStateNotifierProvider.notifier);

    // レシピ作成者情報をレシピに追加
    final user = ref.watch(userProvider);

    final usePantryOnly = useState(false);
    
    final asyncCustomize = ref.watch(customizeNotifierProvider);

    final buttonStates = useState(List<bool>.filled(12, false));
    final budgetState = useState(500.0);
    final timeState = useState(30.0);
    final searchKeywordState = useState('');
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
      budgetState.value = 500;
      timeState.value = 30;
      servingsState.value = 1;
      searchKeywordState.value = '';
    }

    // 食糧庫のみ使用チェックボックス
    final checkBox = Row(
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
    );

    Widget dialog;

    switch(genState){
      case GenerateState.initial:
        dialog = SizedBox.shrink();
        break;
      case GenerateState.generatingRecipe:
        dialog = dialog = Dialog(text: "レシピ生成中...");
        break;
      case GenerateState.generatingImage:
        dialog = Dialog(text: "レシピ画像生成中...");
        break;
      case GenerateState.storingImage:
        dialog = Dialog(text: "画像保存中...");
        break;
      case GenerateState.registeringRecipe:
        dialog = Dialog(text: "レシピ保存中...");
        break;
      case GenerateState.error:
        dialog = Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("レシピ生成に失敗しました"),
              ElevatedButton(
                onPressed: () => notifier.updateState(GenerateState.initial),
                child: Text("レシピ生成画面に戻る")
              )
            ],
          ),
        );
    }

    return SizedBox.expand(
      child: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  checkBox,
                  usePantryOnly.value
                      ? SizedBox.shrink()
                      : Column(
                          children: [
                            SizedBox(
                              height: 40,
                              child: TextField(
                                onChanged: (value) => searchKeywordState.value = value,
                                style: const TextStyle(fontSize: 15),
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
                  Text("予算: ${budgetState.value.toInt()} 円"),
                  Slider(
                    value: budgetState.value,
                    min: 0,
                    max: 1500,
                    divisions: 100,
                    label: '${budgetState.value.toInt()} 円',
                    activeColor: Colors.orange,
                    inactiveColor: Colors.orange.shade100,
                    onChanged: (value) => budgetState.value = value,
                  ),
                  Text("調理時間: ${timeState.value.toInt()} 分"),
                  Slider(
                    value: timeState.value,
                    min: 0,
                    max: 90,
                    divisions: 10,
                    label: '${timeState.value.toInt()} 分',
                    activeColor: Colors.orange,
                    inactiveColor: Colors.orange.shade100,
                    onChanged: (value) => timeState.value = value,
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
                            // 生成生成・登録処理
                            final notifier = ref.read(generateStateNotifierProvider.notifier);
                            final recipeId = await notifier.genAndStoreRecipe(usePantryOnly, buttonStates, budgetState, timeState, servingsState, searchKeywordState, buttonLabels);
                            // レシピIDを状態管理に保存
                            final recipeIdNotifier = ref.read(recipeIdProvider.notifier);
                            recipeIdNotifier.state = recipeId;
                            // レシピの詳細画面に遷移
                            final contentNotifier = ref.read(homeContentTypeProvider.notifier);
                            contentNotifier.state = ContentType.recipe;
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
            ),
          ),
          Center(child: dialog),
        ],
      ),
    );
  }
}

class Dialog extends StatelessWidget {
  const Dialog({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {

    final content = Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(text, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 24),
        const CircularProgressIndicator(),
      ],
    );

    final contentContainer = Center(
      child: Container(
        width: 250,
        height: 300,
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: content
      ),
    );

    return Stack(
      children: [
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(
              color: Colors.black.withOpacity(0.2), // ぼかし＋半透明
            ),
          ),
        ),
        contentContainer,
      ]
    );
  }
}