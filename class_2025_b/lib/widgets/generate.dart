import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:class_2025_b/routers/router.dart';
import 'package:class_2025_b/states/user_state.dart';

class GenerateWidget extends ConsumerWidget {
  const GenerateWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    final column = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("レシピ生成画面"),
        ElevatedButton(
          onPressed: () => AppRouter.goToRecipe(context, "recipeId"),
          child: const Text("レシピ生成ボタン")
        ),
      ],
    );
    return Center(
      child: column,
    );
  }
}