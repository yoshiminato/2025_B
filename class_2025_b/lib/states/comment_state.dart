import 'package:flutter_riverpod/flutter_riverpod.dart';

// コメントの状態管理
final commentProvider = StateProvider<String>((ref) {
  return ""; // 初期値はnull
});