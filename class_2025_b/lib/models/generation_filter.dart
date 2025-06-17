


// 生成するﾚｼﾋﾟの条件に関する情報をまとめるクラス
class GenerationFilter{
  final List<String> keywords = [];             // 材料キーワード(生成時)
  final Map<String, bool> moods = {};           // 気分キーワード(true or false)
  final int budget = 500;                       // 予算
  final int time = 30;                          // 調理時間(分)
  final int servings = 2;                       // 何人分か
  final List<String> allergy = [];              // アレルギー食材
  final Map<String, bool> isToolAvailable = {}; // 使用可能な調理器具(true or false)
  /*
     そのほかﾚｼﾋﾟ生成時に必要な条件があればここに追加
  */
}