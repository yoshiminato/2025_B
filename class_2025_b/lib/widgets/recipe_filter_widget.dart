import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class RecipeFilterWidget extends HookConsumerWidget {
  const RecipeFilterWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final buttonLabels = [
      '濃厚な', 'スパイシー', 'ジューシー',
      'さっぱりした', 'こってり', '淡泊な',
      'クセになる', 'うま味', 'まろやか',
      'コク深い', '香ばしい', '素朴な',
    ];
    final buttonStates = useState(List<int>.filled(12, 0));
    final budgetValue = useState(500.0);
    final timeValue = useState(30.0);
    final servingValue = useState(1.0);
    final searchKeyword = useState('');

    void resetFilters() {
      buttonStates.value = List<int>.filled(12, 0);
      budgetValue.value = 500;
      timeValue.value = 30;
      servingValue.value = 1;
      searchKeyword.value = '';
    }

    void startSearch() {
      final Map<String, String> attributes = {};
      for (int i = 0; i < buttonLabels.length; i++) {
        if (buttonStates.value[i] == 1) {
          attributes[buttonLabels[i]] = '強';
        } else if (buttonStates.value[i] == -1) {
          attributes[buttonLabels[i]] = '弱';
        }
      }
      debugPrint('--- フィルター条件 ---');
      debugPrint('検索キーワード: ${searchKeyword.value}');
      debugPrint('予算: ${budgetValue.value.toInt()} 円');
      debugPrint('調理時間: ${timeValue.value.toInt()} 分');
      debugPrint('分量: ${servingValue.value.toInt()} 人前');
      debugPrint('属性:');
      attributes.forEach((key, value) {
        debugPrint(' - $key : $value');
      });
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            onChanged: (value) => searchKeyword.value = value,
            decoration: InputDecoration(
              hintText: 'レシピを検索',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 24),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 2.5,
            children: List.generate(buttonLabels.length, (index) {
              final state = buttonStates.value[index];
              final color = state == 1
                  ? Colors.red
                  : state == -1
                      ? Colors.blue
                      : Colors.grey.shade300;
              final textColor = state == 0 ? Colors.black : Colors.white;

              return ElevatedButton(
                onPressed: () {
                  final newStates = List<int>.from(buttonStates.value);
                  newStates[index] = (newStates[index] + 2) % 3 - 1;
                  buttonStates.value = newStates;
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
          Text("分量: ${servingValue.value.toInt()} 人前"),
          Slider(
            value: servingValue.value,
            min: 1,
            max: 10,
            divisions: 5,
            label: '${servingValue.value.toInt()} 人前',
            activeColor: Colors.orange,
            inactiveColor: Colors.orange.shade100,
            onChanged: (value) => servingValue.value = value,
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
                  onPressed: startSearch,
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
