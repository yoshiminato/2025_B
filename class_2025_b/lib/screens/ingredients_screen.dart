import 'package:class_2025_b/services/kv_service.dart';
import 'package:flutter/material.dart';

class IngredientsScreen extends StatefulWidget {
  const IngredientsScreen({super.key});

  @override
  State<IngredientsScreen> createState() => _IngredientsScreenState();
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
                        trailing: Icon(Icons.edit),
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
                await kvservice.addValue(KeyType.stockitemnameId, result['name']);
                await kvservice.addValue(KeyType.stockitemcountId, result['count']);
                await kvservice.addValue(KeyType.stockitemexpiryId, result['expiry']);
                setState(() {}); // 追加後に再描画
              }
            },
            child: Icon(Icons.add),
            backgroundColor: Colors.orange,
          ),
        ),
      ],
    );
  }
}

final kvservice = KVService();

//食材を入力してsharedpreferencesに保存する画面
class AddIngredientScreen extends StatelessWidget {
  const AddIngredientScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final nameController = TextEditingController();
    final countController = TextEditingController();
    final expiryController = TextEditingController();

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