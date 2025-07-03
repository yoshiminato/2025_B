import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class RecipeFilterWidget extends ConsumerStatefulWidget {
  const RecipeFilterWidget({super.key});

  @override
  ConsumerState<RecipeFilterWidget> createState() => _RecipeFilterWidgetState();
}

class _RecipeFilterWidgetState extends ConsumerState<RecipeFilterWidget> {
  final List<String> buttonLabels = [
    '濃厚な', 'スパイシー', 'ジューシー',  //クイック条件となる形容詞群
    'さっぱりした', 'こってり', '淡泊な',
    'クセになる', 'うま味', 'まろやか',
    'コク深い', '香ばしい', '素朴な',
  ];

  List<int> buttonStates = List.filled(12, 0);
  double budgetValue = 500;
  double timeValue = 30;
  double servingValue = 1;
  String searchKeyword = '';

  void _resetFilters() {
    setState(() {
      buttonStates = List.filled(12, 0);
      budgetValue = 500;
      timeValue = 30;
      servingValue = 1;
      searchKeyword = '';
    });
  }

  void _startSearch() {
    final Map<String, String> attributes = {};
    for (int i = 0; i < buttonLabels.length; i++) {
      if (buttonStates[i] == 1) {
        attributes[buttonLabels[i]] = '強';
      } else if (buttonStates[i] == -1) {
        attributes[buttonLabels[i]] = '弱';
      }
    }

    print('--- フィルター条件 ---');
    print('検索キーワード: $searchKeyword');
    print('予算: ${budgetValue.toInt()} 円');
    print('調理時間: ${timeValue.toInt()} 分');
    print('分量: ${servingValue.toInt()} 人前');
    print('属性:');
    attributes.forEach((key, value) {
      print(' - $key : $value');  //現在の出力内容：print()で以下を出力
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(  //検索バー
            onChanged: (value) => setState(() => searchKeyword = value),
            decoration: InputDecoration(
              hintText: 'レシピを検索',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 24),
          GridView.count(  //形容詞ボタン群
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 2.5,
            children: List.generate(buttonLabels.length, (index) {
              final state = buttonStates[index];
              final color = state == 1
                  ? Colors.red  //強化
                  : state == -1
                      ? Colors.blue  //抑制
                      : Colors.grey.shade300;  //中立(初期状態)
              final textColor = state == 0 ? Colors.black : Colors.white;

              return ElevatedButton(
                onPressed: () {
                  setState(() {
                    buttonStates[index] = (buttonStates[index] + 2) % 3 - 1; //内部属性：List<int> buttonStates で記録され、開始時に出力（強化/抑制の重みづけに活用可能）
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  shape: const StadiumBorder(),
                ),
                child: Text(
                  buttonLabels[index],
                  style: TextStyle(color: textColor),
                ),
              );
            }),
          ),
          const SizedBox(height: 32),
          Text("予算: ${budgetValue.toInt()} 円"),
          Slider(
            value: budgetValue,
            min: 0,
            max: 1500,
            divisions: 100,
            label: '${budgetValue.toInt()} 円',
            activeColor: Colors.orange,
            inactiveColor: Colors.orange.shade100,
            onChanged: (value) => setState(() => budgetValue = value),
          ),
          Text("調理時間: ${timeValue.toInt()} 分"),
          Slider(
            value: timeValue,
            min: 0,
            max: 90,
            divisions: 10,
            label: '${timeValue.toInt()} 分',
            activeColor: Colors.orange,
            inactiveColor: Colors.orange.shade100,
            onChanged: (value) => setState(() => timeValue = value),
          ),
          Text("分量: ${servingValue.toInt()} 人前"),
          Slider(
            value: servingValue,
            min: 1,
            max: 10,
            divisions: 5,
            label: '${servingValue.toInt()} 人前',
            activeColor: Colors.orange,
            inactiveColor: Colors.orange.shade100,
            onChanged: (value) => setState(() => servingValue = value),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _resetFilters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("リセット"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(  //役割：現在の選択条件を使って検索処理（未実装）を呼び出す(53行目)
                  onPressed: _startSearch,
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
  }
}
