import 'package:flutter/material.dart';
import 'dart:io';
import 'package:class_2025_b/global.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:class_2025_b/models/recipe_model.dart';
import 'package:class_2025_b/states/recipe_id_state.dart';
import 'package:class_2025_b/states/search_sort_state.dart';
import 'package:class_2025_b/states/recent_recipes_state.dart';
import 'package:class_2025_b/states/favorite_recipes_state.dart';
import 'package:class_2025_b/states/user_recipe_state.dart';
import 'package:class_2025_b/states/history_recipe_id_state.dart';
import 'package:class_2025_b/states/home_state.dart';
import 'package:class_2025_b/states/search_state.dart';


class SearchDefaultWidget extends ConsumerWidget {
  const SearchDefaultWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final asyncRecentRecipes = ref.watch(recentRecipesProvider);
    final asyncFavoriteRecipes = ref.watch(favoriteRecipesProvider);
    final asyncUsersRecipes = ref.watch(usersRecipesProvider);
    final asyncHistryRecipes = ref.watch(historyRecipesProvider);

    final column = Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center, // 左寄せに変更
      children: [
        buildRecipeSection(
          "最近生成されたレシピ",
          asyncRecentRecipes, 
          Colors.pink,
        ),
        const SizedBox(height: 20),
        buildRecipeSection(
          "お気に入りレシピ", 
          asyncFavoriteRecipes, 
          Colors.blue,
        ),
        const SizedBox(height: 20),
        buildRecipeSection(
          "自分のレシピ", 
          asyncUsersRecipes, 
          Colors.green,
        ),
        const SizedBox(height: 20),
        buildRecipeSection(
          "閲覧履歴", 
          asyncHistryRecipes, 
          Colors.orange,
        ),
      ],
    );
    return SingleChildScrollView(
      child: column,
    );
  }
}

final double imageSize = 70; // カルーセルカードの画像サイズ

// レシピセクションを構築する関数
Widget buildRecipeSection(String title, AsyncValue<List<Recipe>> asyncRecipe, Color color) {

  // ヘッダー部分
  final header = Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))
  );

  // コンテンツ部分
  final content = asyncRecipe.when(
    data: (recipes) {
      return SizedBox(
        height: 120,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: recipes.length,
          itemBuilder: (context, index) {
            return Container(
              width: 100,
              margin: EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: CarouselCard(recipe: recipes[index]),
            );
          },
        ),
      );
    },
    error: (error, stack) => Center(child: Text("エラーが発生しました: $error")),
    loading: () => const Center(child: CircularProgressIndicator()),
  );

  // ヘッダーとコンテンツをまとめて返す
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      header,
      content,
    ],
  );
}

// ソート選択画面
class SortSelecterWidget extends ConsumerWidget {

  const SortSelecterWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final sortType = ref.watch(sortStateProvider);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('ソート順を選択', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            RadioTileWidget(title: "新しい順", value: SortType.newest, groupValue: sortType),
            RadioTileWidget(title: "古い順", value: SortType.oldest, groupValue: sortType),
            RadioTileWidget(title: "価格順", value: SortType.cost, groupValue: sortType),
            RadioTileWidget(title: "調理時間順", value: SortType.time, groupValue: sortType),
            RadioTileWidget(title: "味", value: SortType.taste, groupValue: sortType),
            RadioTileWidget(title: "作りやすさ", value: SortType.ease, groupValue: sortType),
            RadioTileWidget(title: "コスパ", value: SortType.cosp, groupValue: sortType),
            RadioTileWidget(title: "おすすめ", value: SortType.reccommend, groupValue: sortType),            
          ],
        ),
      ),
    );
  }
}

// ソート種類選択画面のラジオボタンウィジェット
class RadioTileWidget extends ConsumerWidget {

  final String title;
  final SortType value;
  final SortType groupValue;
  const RadioTileWidget({super.key, required this.title, required this.value, required this.groupValue});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RadioListTile<SortType>(
      title: Text(title),
      value: value,
      groupValue: groupValue,
      onChanged: (value) {
        if (value != null) {
          ref.read(sortStateProvider.notifier).state = value;
          final searchResultNotifier = ref.read(searchResultNotifierProvider.notifier);
          searchResultNotifier.updateSearchResult();
          Navigator.of(context).pop();
        }
      },
    );
  }
}

// カルーセルカードウィジェット(ﾚｼﾋﾟの検索結果表示時に使用)
class CarouselCard extends ConsumerWidget {
  final Recipe recipe;

  const CarouselCard({super.key, required this.recipe});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    String? url;

    final path = recipe.imagePath;

    // ホストとポートの(画像生成時の環境による違いの)整合性をとる
    if(path != null){
      url = getUrl(storageHost, storagePort, path);
    }

    final imageContainer = SizedBox(
      width: imageSize,
      height: imageSize,
      child: url != null
        ? Image.network(ensureAltMediaParameter(url), fit: BoxFit.cover)
        : Image.asset("assets/images/noImage.png", fit: BoxFit.cover,),
    );

    final column = Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        imageContainer,
        Center(
          child: Text(
            recipe.title, 
            style: const TextStyle(fontSize: 9),
            overflow: TextOverflow.ellipsis,
            maxLines: 2, // 1行だけ表示
          ),
        ),
        
      ],
    );

    // タップ可能なウィジェット
    return InkWell(
        onTap: () {
          // レシピの詳細画面に遷移する処理を追加
          final recipeIdNotifier = ref.read(recipeIdProvider.notifier);
          recipeIdNotifier.state = recipe.id;
          // レシピの詳細画面に遷移
          final contentNotifier = ref.read(homeContentTypeProvider.notifier);
          contentNotifier.state = ContentType.recipe;
        },
        child: Padding(
          padding: EdgeInsets.all(2.0),
          child: column,
        ),
      );

  }
}
