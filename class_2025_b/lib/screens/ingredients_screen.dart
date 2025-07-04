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
  const IconButtons({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddIngredientScreen(index: index,)),
            );
          }, 
          icon: Icon(Icons.edit)
        ),
        IconButton(
          onPressed: () async {
            // 削除処理を実装
            final kvservice = KVService();

            await kvservice.removeValueFromKeyTypeByIndex(KeyType.stockitemnameId, index);
            await kvservice.removeValueFromKeyTypeByIndex(KeyType.stockitemcountId, index);
            await kvservice.removeValueFromKeyTypeByIndex(KeyType.stockitemexpiryId, index);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('食材を削除しました')),
            );
            // 画面を再描画
            (context as Element).reassemble();
          }, 
          icon: Icon(Icons.delete, color: Colors.red,)
        )
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

    return Stack(
      children: [
        Column(
          children: [
            Container(height: 40, color: Colors.orange.shade50, alignment: Alignment.center, child: Text("食料庫")),
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
                  final length = [names.length, counts.length, expiries.length].reduce((a, b) => a < b ? a : b);
                  
                  //取得した食材データをリスト表示
                  return ListView.builder(
                    itemCount: length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text('${names[index]}（${counts[index]}個）'),
                        subtitle: Text('賞味期限: ${expiries[index]}'),
                        trailing: IconButtons(index: index,)
                      );
                    },
                  );
                },
              ),
            ),
            Container(height: 30, color: Colors.orange.shade50, alignment: Alignment.center, child: Text("下帯")),
          ],
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: () async {
              print("食材追加ボタンが押されました");
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddIngredientScreen()),
              );
              if (result != null) {
                print("食材追加: ${result['name']}, ${result['count']}, ${result['expiry']}");
                await kvservice.addValueForKeyType(KeyType.stockitemnameId, result['name']);
                await kvservice.addValueForKeyType(KeyType.stockitemcountId, result['count']);
                await kvservice.addValueForKeyType(KeyType.stockitemexpiryId, result['expiry']);
                setState(() {}); // 追加後に再描画
              }
            },
            backgroundColor: Colors.orange,
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}

final kvservice = KVService();

//食材を入力してsharedpreferencesに保存する画面
class AddIngredientScreen extends HookWidget {
  final int index;
  const AddIngredientScreen({super.key, int? index})
  : index = index ?? -1;

  @override
  Widget build(BuildContext context) {

    final nameController   = useTextEditingController();
    final countController  = useTextEditingController();
    final expiryController = useTextEditingController();

    final rebuildTrigger = useState(0);

    useEffect(() {

      debugPrint("AddIngredientScreen useEffect called with index: $index");
      if(index != -1){
        // 編集モードの場合、既存のデータを読み込む
        () async {
          final names = await kvservice.getValuesFromKeyType(KeyType.stockitemnameId);
          final counts = await kvservice.getValuesFromKeyType(KeyType.stockitemcountId);
          final expiries = await kvservice.getValuesFromKeyType(KeyType.stockitemexpiryId);

          if (index < names.length) {
            nameController.text = names[index];
            countController.text = counts[index];
            expiryController.text = expiries[index];
          }

          rebuildTrigger.value++; // コントローラーの初期化をトリガー
        }();
      }
    }, [index]);
      // else {
      //   // 新規追加モードの場合、コントローラーを初期化
      //   nameController.clear();
      //   countController.clear();
      //   expiryController.clear();
      // }
   

    return Scaffold(
      appBar: AppBar(title: Text('食材を追加')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: '食材名'),
            ),
            SizedBox(height: 12),

            TextField(
              controller: countController,
              decoration: InputDecoration(labelText: '個数'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 12),

            TextField(
              controller: expiryController,
              decoration: InputDecoration(labelText: '賞味期限 (例: 2025/07/01)'),
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
              child: Text('追加'),
            ),
          ],
        ),
      ),
    );
  }
}