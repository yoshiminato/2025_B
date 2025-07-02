import 'package:class_2025_b/routers/router.dart';
import 'package:class_2025_b/services/kv_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class CustomSettingScreen extends StatelessWidget {
  const CustomSettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => AppRouter.goToHome(context),
        ),
        title: const Text("カスタマイズ設定"),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const NumInputWidget(),
              const SizedBox(height: 20),
              const AllergyWidget(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => AppRouter.goToHome(context),
                child: const Text("ホームに戻る")
              ),
            ],
          ),
        ),
      )
    );
  }
}

const numLimit = 10;

class NumInputWidget extends HookWidget {
  const NumInputWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final kvService = KVService();
    final selectedServings = useState(1);

    // 初回表示時にKVから値を読み込み
    useEffect(() {
      Future.microtask(() async {
        final servings = await kvService.getValueFromKeyType(KeyType.servings);
        selectedServings.value = int.parse(servings);
      });
      return null;
    }, []);

    return Row(
      children: [
        const Text("分量   :    "),
        DropdownButton<int>(
          value: selectedServings.value,
          items: [
            for (var i = 1; i <= numLimit; i++)
              DropdownMenuItem(value: i, child: Text("$i"))
          ],
          onChanged: (value) async {
            if (value != null) {
              selectedServings.value = value;
              await kvService.saveValueForKeyType(KeyType.servings, value.toString());
            }
          },
        ),
        const Text("人前")
      ],
    );
  }
}


class AllergyWidget extends HookWidget {
  const AllergyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final kvService = KVService();
    final controllers = useState<List<TextEditingController>>([
      TextEditingController()
    ]);

    // 初回表示時にKVからアレルギーリストを読み込み
    useEffect(() {
      Future.microtask(() async {
        final allergys = await kvService.getValuesFromKeyType(KeyType.allergys);
        if (allergys.isNotEmpty) {
          // 古いコントローラを削除
          for (var c in controllers.value) {
            c.dispose();
          }
          // 新しいコントローラを作成
          controllers.value = allergys.map((allergy) => 
              TextEditingController(text: allergy)).toList();
        }
      });
      return () {
        for (var c in controllers.value) {
          c.dispose();
        }
      };
    }, []);

    void addTextField() {
      controllers.value = [
        ...controllers.value,
        TextEditingController()
      ];
    }

    void removeTextField(int index) {
      if (controllers.value.length > 1) {
        final newList = List<TextEditingController>.from(controllers.value);
        newList[index].dispose();
        newList.removeAt(index);
        controllers.value = newList;
        // 削除後にKVを更新
        Future.microtask(() async {
          final allergys = controllers.value.map((c) => c.text.trim())
              .where((text) => text.isNotEmpty).toList();
          await kvService.saveValuesForKeyType(KeyType.allergys, allergys);
        });
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 16.0, right: 16.0),
          child: Text("アレルギー："),
        ),
        Expanded(
          child: Column(
            children: [
              ...controllers.value.asMap().entries.map((entry) {
                int index = entry.key;
                TextEditingController controller = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            hintText: "アレルギー${index + 1}",
                            suffixIcon: controllers.value.length > 1
                                ? IconButton(
                                    icon: const Icon(Icons.remove_circle),
                                    onPressed: () => removeTextField(index),
                                  )
                                : null,
                          ),
                          onChanged: (value) {
                            // アレルギーリストをKVに保存
                            Future.microtask(() async {
                              final allergys = controllers.value.map((c) => c.text.trim())
                                  .where((text) => text.isNotEmpty).toList();
                              await KVService().saveValuesForKeyType(KeyType.allergys, allergys);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: addTextField,
                  icon: const Icon(Icons.add),
                  label: const Text("追加"),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
