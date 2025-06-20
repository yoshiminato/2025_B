import 'package:flutter_riverpod/flutter_riverpod.dart';


enum ContentType{
  generate,
  search,
  recipe,
}

// ホーム画面のコンテンツの状態を管理するプロバイダ
final currentContentTypeProvider = StateProvider<ContentType>((ref) {
  return ContentType.generate; // 初期画面は生成画面
});