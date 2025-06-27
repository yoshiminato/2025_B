


// 生成するﾚｼﾋﾟの条件に関する情報をまとめるクラス
class Filter{
  final List<String> ingredients;             // 材料キーワード(生成時)
  final Map<String, bool> moods;           // 気分キーワード(true or false)
  final int budget;                       // 予算
  final int time;                          // 調理時間(分)
  final int servings;                       // 何人分か
  final List<String> allergy;              // アレルギー食材
  final Map<String, bool> isToolAvailable; // 使用可能な調理器具(true or false)
  /*
     そのほかﾚｼﾋﾟ生成時に必要な条件があればここに追加
  */

  Filter({
    required this.ingredients,
    required this.moods,
    required this.budget,
    required this.time, 
    required this.servings,
    required this.allergy,
    required this.isToolAvailable,
  });
}

final sampleFilter = Filter(
  ingredients: ["キャベツ", "ピーマン", "オレンジ"],
  moods: {
    "元気": true,
    "疲れ": false,
    "リラックス": true,
    "おしゃれ": false,
  },
  budget: 1000,
  time: 30,
  servings: 2,
  allergy: ["卵", "乳製品"],
  isToolAvailable: {
    "フライパン": true,
    "鍋": false,
    "オーブン": true,
    "電子レンジ": true,
  },
);