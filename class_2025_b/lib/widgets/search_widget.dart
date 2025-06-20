import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class SearchWidget extends HookWidget {
  const SearchWidget({super.key});

  @override
  Widget build(BuildContext context) {

    final hasResult = useState(false);

    final searchTextField = TextField(
      decoration: InputDecoration(
        labelText: "レシピを検索",
        hintText: "材料を入力",
        border: OutlineInputBorder(),
      ),
      onChanged: (value) {
        // 検索テキストが入力されたら結果があると仮定
        hasResult.value = value.isNotEmpty;
      },
    );
    return Center(
      child: Text("検索画面"),
    );
  }
}