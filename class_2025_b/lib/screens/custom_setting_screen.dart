import 'package:class_2025_b/routers/router.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:class_2025_b/states/custom_state.dart';


// 主要8品目と主要調理器具
const List<String> majorAllergys = [
  '卵', '乳', '小麦', 'そば', '落花生', 'えび', 'かに', 'くるみ'
];
const List<String> majorTools = [
  '電子レンジ', 'オーブン', 'トースター', 'フライパン', '鍋', '炊飯器', '包丁', 'まな板'
];

class CustomSettingScreen extends ConsumerWidget {
  const CustomSettingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    // カスタマイズ設定の状態とNotifierを取得
    final model = ref.watch(customizeNotifierProvider);
    final notifier = ref.read(customizeNotifierProvider.notifier);

    final body = model.when(
      data: (data) {
        return SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 分量
              const SizedBox(height: 24),
              IntDropDownWidget(
                title: "分量",
                value: data.servings,
                rangeMin: 1,
                rangeMax: 10,
                measurementUnit: "人前",
                onChanged: notifier.setServings,
              ),
              const SizedBox(height: 24),
              // アレルギー
              SelectableButtonList(
                title: "主要アレルギー（8品目）", 
                items: majorAllergys,
                selectedItems: data.allergys,
                onTap: notifier.toggleAllergy,
              ),
              const SizedBox(height: 24),
              // 調理器具
              SelectableButtonList(
                title: "使用可能な調理器具", 
                items: majorTools,
                selectedItems: data.availableTools,
                onTap: notifier.toggleTool,
              ), 
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => notifier.saveSettings(),
                child: const Text("設定を保存"),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text("エラーが発生しました: $error")),
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => AppRouter.goToHome(context),
        ),
        title: const Text("カスタマイズ設定"),
      ),
      body: body
    );
  }
}

// int数値のドロップダウンウィジェット
class IntDropDownWidget extends ConsumerWidget {

  final String title;
  final int value;
  final int rangeMin;
  final int rangeMax;
  final String measurementUnit; // 単位
  final void Function(int) onChanged;

  const IntDropDownWidget({
    super.key, 
    required this.title, 
    required this.value,
    this.rangeMin = 1, // デフォルトは1
    this.rangeMax = 10, // デフォルトは10
    this.measurementUnit = "", // デフォルトは空文字
    required this.onChanged
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text("分量", style: TextStyle(fontWeight: FontWeight.bold)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButton<int>(
              value: value,
              items: [
                for (var i = rangeMin; i <= rangeMax; i++)
                  DropdownMenuItem(value: i, child: Text("$i"))
              ],
              onChanged: (value) {
                if (value != null) onChanged(value);
              },
            ),
            Text(measurementUnit.toString()),
          ],
        ),
      ],
    );
  }
}


// 選択可能なボタンリストウィジェット
class SelectableButtonList extends ConsumerWidget {

  final String title;
  final List<String> items;
  final List<String> selectedItems;
  final void Function(String) onTap;
  const SelectableButtonList({super.key, required this.title, required this.items, required this.selectedItems, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((item) {
            return FilterChip(
              label: Text(item),
              selected: selectedItems.contains(item), // 選択状態は外部で管理
              onSelected: (selected) => onTap(item), // 選択状態の変更処理を外部で実装
              selectedColor: Colors.red.shade200,
            );
          }).toList(),
        ),
      ],
    );
  }
}