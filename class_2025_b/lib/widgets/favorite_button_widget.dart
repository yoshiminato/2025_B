import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:class_2025_b/states/favorite_recipe_id_state.dart';
import 'package:class_2025_b/states/recipe_id_state.dart';

/* いいねボタンウィジェット */
class FavoriteButtonWidget extends ConsumerWidget {

  const FavoriteButtonWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final recipeId = ref.watch(recipeIdProvider);

    if(recipeId == null) {
      return const SizedBox.shrink(); // レシピIDがない場合は何も表示しない
    }

    // いいね状態を取得するためのプロバイダを監視
    final favoriteRecipeIds = ref.watch(favoriteRecipeIdNotifierProvider);

    // 取得した状態からこのレシピがいいねされいるかを取得 true/false
    final isFavorite = favoriteRecipeIds.when(
      data: (ids) => ids?.contains(recipeId) ?? false,
      loading: () => false,
      error: (error, stack) {
        debugPrint("FavoriteButtonWidget: いいね状態の取得に失敗: $error");
        return false;
      },
    );

    final header = SizedBox(
      child: const Text(
        'お気に入り',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    final favoriteButton = IconButton(
      icon: Icon(
        Icons.favorite,
        color: isFavorite ? Colors.pink : Colors.grey,
      ),
      onPressed: () {
        final notifier = ref.read(favoriteRecipeIdNotifierProvider.notifier);
        if (isFavorite) {
          notifier.removeValueFromKeyType(recipeId);
        } else {
          notifier.addValueForKeyType(recipeId);
        }
      },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        header,
        const SizedBox(height: 16),
        Center(
          child: favoriteButton,
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            isFavorite ? 'お気に入りに追加済み' : 'お気に入りに追加',
            style: TextStyle(
              color: isFavorite ? Colors.pink : Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}