import 'package:flutter_riverpod/flutter_riverpod.dart';

// 検索結果のソートタイプを定義する列挙型
enum SortType {
  newest, // 新しい順
  oldest, // 古い順
  cost, // 価格順
  time,//調理時間
  taste,//味
  ease,//作りやすさ
  cosp,//コストパフォーマンス
  reccommend//おすすめ
}

// 検索結果のソート状態を管理するプロバイダ
final sortStateProvider = StateProvider<SortType>((ref) {
  // デフォルトのソート順を設定
  return SortType.time; // 新しい順
});