import 'package:class_2025_b/routers/router.dart';
import 'package:class_2025_b/screens/ingredients_screen.dart';
import 'package:class_2025_b/services/kv_service.dart';
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

    final model = ref.watch(customizeNotifierProvider);
    final notifier = ref.read(customizeNotifierProvider.notifier);

    final body = model.when(
      data: (data) {
        return SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 分量
                const SizedBox(height: 24),
                const Text("分量", style: TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DropdownButton<int>(
                      value: data.servings,
                      items: [
                        for (var i = 1; i <= 10; i++)
                          DropdownMenuItem(value: i, child: Text("$i"))
                      ],
                      onChanged: (value) {
                        if (value != null) notifier.setServings(value);
                      },
                    ),
                    const Text("人前"),
                  ],
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