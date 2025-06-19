import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:class_2025_b/widgets/recipe.dart';
import 'package:class_2025_b/widgets/generate.dart';

enum Content {
  generate,
  recipe,
}

final homeContentIndexProvider = StateProvider<Content>((ref) {
  return Content.generate; // 初期値は生成画面
});

final recipeIdProvider = StateProvider<String?>((ref) {
  return null; // 初期値はnull
});