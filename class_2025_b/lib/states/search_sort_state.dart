import 'package:flutter_riverpod/flutter_riverpod.dart';

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

final sortStateProvider = StateProvider<SortType>((ref) {
  // デフォルトのソート順を設定
  return SortType.time; // 新しい順
});