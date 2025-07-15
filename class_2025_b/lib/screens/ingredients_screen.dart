import 'package:class_2025_b/services/kv_service.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter/material.dart';

class IngredientsScreen extends StatefulWidget {
  const IngredientsScreen({super.key});

  @override
  State<IngredientsScreen> createState() => _IngredientsScreenState();
}

class IconButtons extends StatelessWidget {
  final int index;
  final VoidCallback setState;
  const IconButtons({super.key, required this.index, required this.setState});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        //追加済み食材の編集と削除
        IconButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddIngredientScreen(index: index),
              ),
            );
            if (result != null) {
              // 編集された食材情報を更新
              final kvservice = KVService(); //デバッグエラー対策で一時コメントアウトした箇所
              await kvservice.modifyValueFromKeyTypeByIndex(
                KeyType.stockitemnameId,
                index,
                result['name'],
              );
              await kvservice.modifyValueFromKeyTypeByIndex(
                KeyType.stockitemcountId,
                index,
                result['count'],
              );
              await kvservice.modifyValueFromKeyTypeByIndex(
                KeyType.stockitemexpiryId,
                index,
                result['expiry'],
              );

              if (!context.mounted) return;
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('食材を更新しました')));
              // 画面を再描画
              setState();
            }
          },
          icon: Icon(Icons.edit),
        ),
        IconButton(
          onPressed: () async {
            // 削除処理を実装
            final kvservice = KVService();

            await kvservice.removeValueFromKeyTypeByIndex(
              KeyType.stockitemnameId,
              index,
            );
            await kvservice.removeValueFromKeyTypeByIndex(
              KeyType.stockitemcountId,
              index,
            );
            await kvservice.removeValueFromKeyTypeByIndex(
              KeyType.stockitemexpiryId,
              index,
            );

            if (!context.mounted) return;
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('食材を削除しました')));
            // 画面を再描画
            setState();
          },
          icon: Icon(
            Icons.delete,
            color: const Color.fromARGB(255, 252, 90, 41),
          ),
        ),
      ],
    );
  }
}

//食材データをsharedpreferencesから取得して表示する
class _IngredientsScreenState extends State<IngredientsScreen> {
  @override
  Widget build(BuildContext context) {
    return buildStockPage(context);
  }

  Widget buildStockPage(BuildContext context) {
    return Container(
      color: Color.fromARGB(255, 253, 250, 246),
      child: Stack(
        children: [
          Column(
            children: [
              //デバッグエラー対策でContainerをMaterialでラップ
              Material(
                color: Color.fromARGB(255, 255, 215, 180),
                child: Container(
                  height: 40,
                  alignment: Alignment.center,
                  child: Text(
                    "食料庫",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Expanded(
                //食材リストを作る
                child: FutureBuilder<List<List<String>>>(
                  future: Future.wait([
                    kvservice.getValuesFromKeyType(KeyType.stockitemnameId),
                    kvservice.getValuesFromKeyType(KeyType.stockitemcountId),
                    kvservice.getValuesFromKeyType(KeyType.stockitemexpiryId),
                  ]),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }
                    final names = snapshot.data![0];
                    final counts = snapshot.data![1];
                    final expiries = snapshot.data![2];
                    final length = [
                      names.length,
                      counts.length,
                      expiries.length,
                    ].reduce((a, b) => a < b ? a : b);

                    //食料０の時の表示
                    if (length == 0) {
                      return Material(
                        color: Color.fromARGB(255, 253, 250, 246),
                        child: Center(
                          child: Text(
                            'no Ingredients',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }
                    //取得した食材データをリスト表示
                    return ListView.builder(
                      itemCount: length,
                      itemBuilder: (context, index) {
                        //デバッグエラー対策でListTileをMaterialでラップ
                        return Material(
                          color: Color.fromARGB(255, 255, 239, 216),
                          child: ListTile(
                            title: Text('${names[index]}（${counts[index]}個）'),
                            subtitle: Text('賞味期限: ${expiries[index]}'),
                            trailing: IconButtons(
                              index: index,
                              setState: () {
                                setState(() {});
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Material(
                color: Colors.orange.shade50,
                child: Container(
                  height: 40,
                  alignment: Alignment.center,
                  child: Text(
                    "下帯",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddIngredientScreen(),
                  ), //食材追加結果を受け取る
                );
                if (result != null) {
                  await kvservice.addValueForKeyType(
                    KeyType.stockitemnameId,
                    result['name'],
                  );
                  await kvservice.addValueForKeyType(
                    KeyType.stockitemcountId,
                    result['count'],
                  );
                  await kvservice.addValueForKeyType(
                    KeyType.stockitemexpiryId,
                    result['expiry'],
                  );
                  setState(() {}); // 追加後に再描画
                }
              },
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}

final kvservice = KVService();

//食材を入力してsharedpreferencesに保存する画面
class AddIngredientScreen extends HookWidget {
  final int index;
  const AddIngredientScreen({super.key, int? index}) : index = index ?? -1;

  @override
  Widget build(BuildContext context) {
    final nameController = useTextEditingController();
    final countController = useTextEditingController();
    final expiryController = useTextEditingController();

    final rebuildTrigger = useState(0);

    useEffect(() {
      if (index != -1) {
        // 編集モードの場合、既存のデータを読み込む
        () async {
          final names = await kvservice.getValuesFromKeyType(
            KeyType.stockitemnameId,
          );
          final counts = await kvservice.getValuesFromKeyType(
            KeyType.stockitemcountId,
          );
          final expiries = await kvservice.getValuesFromKeyType(
            KeyType.stockitemexpiryId,
          );

          if (index < names.length) {
            nameController.text = names[index];
            countController.text = counts[index];
            expiryController.text = expiries[index];
          }

          rebuildTrigger.value++; // コントローラーの初期化をトリガー
        }();
      }
      return null; //デバッグエラー対策で一時コメントアウト
    }, [index]);

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 253, 250, 246),
      appBar: AppBar(
        title: Text('食材を追加'),
        backgroundColor: Color.fromARGB(255, 255, 215, 180),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: '食材名',
                floatingLabelStyle: TextStyle(color: Colors.black),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
              cursorColor: Colors.black,
            ),
            SizedBox(height: 12),
            TextField(
              controller: countController,
              decoration: InputDecoration(
                labelText: '個数',
                floatingLabelStyle: TextStyle(color: Colors.black),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
              cursorColor: Colors.black,
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 12),
            TextField(
              controller: expiryController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: '賞味期限 (例: 2025/07/01)',
                floatingLabelStyle: TextStyle(color: Colors.black),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
              onTap: () async {
                final initialDate = DateTime.now();
                final newDate = await showDatePicker(
                  context: context,
                  initialDate: initialDate,
                  firstDate: DateTime(DateTime.now().year - 2),
                  lastDate: DateTime(DateTime.now().year + 2),
                  builder: (BuildContext context, Widget? child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(
                          primary: Colors.orange, // ヘッダー背景色 & OK/キャンセルのボタン
                          onPrimary: Colors.white, // ヘッダーのテキスト色
                          onSurface: const Color.fromARGB(
                            221,
                            57,
                            32,
                            32,
                          ), // 日付の文字色
                        ),
                      ),
                      child: child!,
                    );
                  },
                );

                if (newDate != null) {
                  expiryController.text =
                      "${newDate.year}/${newDate.month.toString().padLeft(2, '0')}/${newDate.day.toString().padLeft(2, '0')}";
                }
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                String name = nameController.text;
                String count = countController.text;
                String expiry = expiryController.text;

                //入力された食材情報を返す
                Navigator.pop(context, {
                  'name': name,
                  'count': count,
                  'expiry': expiry,
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 24,
                ),
                textStyle: const TextStyle(fontSize: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('追加'),
            ),
          ],
        ),
      ),
    );
  }
}
