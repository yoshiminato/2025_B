import 'package:flutter/material.dart';
/*
  レシピ生成結果を表示する画面
  2025/07/02 安田萌乃　データに合わせてレシピ情報を表示＆評価を格納するように実装
*/

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
      home: const Recipe_result(title: 'レシピ生成結果'), //ここをいじればページの左上のタイトルが変わります
    );
  }
}

class Recipe_result extends StatefulWidget {
  const Recipe_result({super.key, required this.title});
  final String title;
  @override
  State<Recipe_result> createState() => _Recipe_resultState();
}

/*レシピ情報*/
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
  //評価スライダーの値(初期値：０　最大値：５)
  int _value_yammy = 0;
  int _value_easy = 0;
  int _value_unique = 0;

  /*
  統合時にはレシピ情報を、打ち込みではなくデータベースから受け取る形にする
  今はダミーのデータを生成している
  Recipe_info：レシピ情報を格納するクラス（レシピタイトル、何人前、調理時間、想定予算）
  Recipe_Ingredients：レシピの材料情報を格納するクラス  （材料名、分量）
  Recipe_Manual：レシピの手順書を格納するクラス（手順番号、説明文）
  レシピ情報を成形して格納する
  */
  //生成結果を成形＆格納する
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

  /*
  統合時には、評価を送信するAPIを実装する
  今はダミー関数として実装
  レシピ評価を送信する関数
  引数はそれぞれ美味しさ、手軽さ、奇抜さ(他評価項目必要なら、すぐ追加します)
   */
  void _sendValue(int score_yammy, int score_easy, int score_unique) {
    //生成レシピの評価を送信
  }

  //スライダーの数字に合わせて色変える
  Color getSliderColor(double value) {
    if (value == 0) return Colors.grey;
    if (value == 1) return Color.fromARGB(255, 246, 216, 70);
    if (value == 2) return const Color.fromARGB(255, 235, 180, 43);
    if (value == 3) return Color.fromARGB(255, 238, 150, 95);
    if (value == 4) return Color.fromARGB(255, 255, 84, 93);
    return const Color.fromARGB(255, 252, 36, 205);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: ListView(
        children: [
          //レシピタイトル＆概要//想定予算、所要時間
          Text(
            '"' + R_info.recipe_title + '"のレシピ',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '想定予算：${R_info.cost}円\n所要時間：${R_info.r_time}分',
            style: TextStyle(fontSize: 15),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          //必要な材料の情報//何人前
          Text(
            '材料(${R_info.number}人前)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 255, 239, 216),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: R_ingredients.map(
                (ing) => Row(
                  children: [
                    Expanded(
                      child: Text(ing.name, textAlign: TextAlign.center),
                    ),
                    Expanded(
                      child: Text(
                        '　　　' + ing.amount,
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
              ).toList(),
            ),
          ),
          const SizedBox(height: 8),

          //レシピ手順書
          Text(
            '手順',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 255, 239, 216),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: R_steps.map(
                (stp) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(
                          '${stp.number}.',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          stp.manual,
                          style: const TextStyle(fontSize: 15),
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ).toList(),
            ),
          ),

          //レシピ情報部とレシピ評価部の境界線
          Column(
            children: [
              Divider(
                color: Color.fromARGB(255, 239, 211, 173),
                thickness: 1,
                height: 32,
                indent: 10,
                endIndent: 10,
              ),
            ],
          ),

          //レシピ評価スライダー
          Text(
            "美味しさ",
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          Slider(
            value: _value_yammy.toDouble(),
            min: 0,
            max: 5,
            divisions: 5,
            label: _value_yammy.round().toString(),
            activeColor: getSliderColor(_value_yammy.toDouble()),
            inactiveColor: Colors.blueGrey,
            onChanged: (value) {
              setState(() {
                _value_yammy = value.toInt();
              });
            },
          ),
          Text(
            "手軽さ",
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          Slider(
            value: _value_easy.toDouble(),
            min: 0,
            max: 5,
            divisions: 5,
            label: _value_easy.round().toString(),
            activeColor: getSliderColor(_value_easy.toDouble()),
            inactiveColor: Colors.blueGrey,
            onChanged: (value) {
              setState(() {
                _value_easy = value.toInt();
              });
            },
          ),
          Text(
            "奇抜さ",
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          Slider(
            value: _value_unique.toDouble(),
            min: 0,
            max: 5,
            divisions: 5,
            label: _value_unique.round().toString(),
            activeColor: getSliderColor(_value_unique.toDouble()),
            inactiveColor: Colors.blueGrey,
            onChanged: (value) {
              setState(() {
                _value_unique = value.toInt();
              });
            },
          ),
          const SizedBox(height: 16),
          //レシピ評価確定ボタン
          IntrinsicWidth(
            child: ElevatedButton(
              onPressed: () {
                _sendValue(_value_easy, _value_easy, _value_unique);
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
              child: Text(
                '☆レシピ評価を送信する☆\n美味しさ：$_value_yammy　手軽さ：$_value_easy　奇抜さ：$_value_unique',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
          //スクロール用の余白(画面遷移ボタンとの重なり対策)
          const SizedBox(height: 128),
        ],
      ),
    );
  }
}
