


// 生成するﾚｼﾋﾟの条件に関する情報をまとめるクラス
class Filter{
  final bool usePantryOnly;
  final List<String> ingredients;             // 材料キーワード(生成時)
  final List<String> attributes;              // 気分キーワード(true or false)
  final int budget;                           // 予算
  final int time;                             // 調理時間(分)
  final int servings;                         // 何人分か
  final List<String> allergy;                 // アレルギー食材
  final List<String> availableTools;    // 使用可能な調理器具(true or false)
  /*
     そのほかﾚｼﾋﾟ生成時に必要な条件があればここに追加
  */

  Filter({
    required this.usePantryOnly,
    required this.ingredients,
    required this.attributes,
    required this.budget,
    required this.time, 
    required this.servings,
    required this.allergy,
    required this.availableTools,
  });
}

final sampleFilter = Filter(
  usePantryOnly: false,
  ingredients: ["リンゴ", "ピーマン", "牛乳"],
  attributes: [
    "濃厚な",
    "スパイシー",
  ],
  budget: 1000,
  time: 30,
  servings: 2,
  allergy: ["卵", "乳製品"],
  availableTools: ["フライパン", "鍋"],
);