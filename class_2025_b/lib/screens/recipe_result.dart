import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
      ),
      home: const Recipe_result(title: 'レシピ生成結果'),
    );
  }
}

class Recipe_result extends StatefulWidget {
  const Recipe_result({super.key, required this.title});
  final String title;

  @override
  State<Recipe_result> createState() => _Recipe_resultState();
}

class Recipe_info {
  final String recipe_title; //レシピタイトル
  final int number; //何人前
  final int r_time; //調理時間(分)
  final int cost; //想定予算

  const Recipe_info(this.recipe_title, this.number, this.r_time, this.cost);
}

class Recipe_Ingredients {
  final String name; //材料名
  final String amount; //分量

  const Recipe_Ingredients(this.name, this.amount);
}

class Recipe_Manual {
  final int number; //手順番号
  final String manual; //説明文

  const Recipe_Manual(this.number, this.manual);
}

class _Recipe_resultState extends State<Recipe_result> {
  int _value = 0;
  int score = 0;
  //生成結果を成型格納する
  final Recipe_info R_info = const Recipe_info('Recipe_Title', 1, 20, 500);

  final List<Recipe_Ingredients> R_ingredients = const [
    Recipe_Ingredients('にんじん', '1本'),
    Recipe_Ingredients('玉ねぎ', '2個'),
  ];

  final List<Recipe_Manual> R_steps = const [
    Recipe_Manual(
      1,
      'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
    ),
    Recipe_Manual(2, 'bbbbbbbbbbbb'),
  ];

  //スライダーの数字に合わせて色変える
  Color getSliderColor(double value) {
    if (value < 0) return Colors.blue;
    if (value > 0) return Colors.red;
    return Colors.grey;
  }

  void _sendValue(int score) {
    //生成レシピの評価を送信
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        //title: Text("aaaa"),
      ),
      body: ListView(
        children: [
          //タイトル
          Text(
            R_info.recipe_title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            '想定予算：${R_info.cost}円\n調理時間：${R_info.r_time}分',
            style: TextStyle(fontSize: 15),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),
          //何人前
          Text(
            '材料(${R_info.number}人前)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 4),
          ...R_ingredients.map(
            (ing) => Row(
              children: [
                Expanded(child: Text(ing.name, textAlign: TextAlign.center)),
                Expanded(
                  child: Text('　　　' + ing.amount, textAlign: TextAlign.left),
                ),
              ],
            ),
          ).toList(),

          const SizedBox(height: 16),
          //レシピ手順書
          Text(
            '手順',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          ...R_steps.map((stp) => Text('${stp.number} ${stp.manual}')).toList(),

          const SizedBox(height: 16),
          //レシピ評価スライダー
          Slider(
            value: _value.toDouble(),
            min: -100,
            max: 100,
            divisions: 200,
            label: _value.round().toString(),
            activeColor: getSliderColor(_value.toDouble()),
            inactiveColor: Colors.blueGrey,
            onChanged: (value) {
              setState(() {
                _value = value.toInt();
              });
            },
          ),
          ElevatedButton(
            onPressed: () {
              _sendValue(_value);
            },
            child: Text('レシピを評価 $_value'),
          ),
        ],
      ),
    );
  }
}
