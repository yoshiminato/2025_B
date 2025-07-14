import 'package:flutter/material.dart';
import 'package:class_2025_b/global.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:class_2025_b/states/search_state.dart';
import 'package:class_2025_b/states/recipe_id_state.dart';
import 'package:class_2025_b/states/home_state.dart';
import 'package:class_2025_b/models/recipe_model.dart';
import 'package:class_2025_b/widgets/star_widget.dart';


const tileImageSize = 70.0;

class SearchResultWidget extends ConsumerWidget {
  const SearchResultWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    // 検索結果をプロバイダから取得
    final searchResult = ref.watch(searchResultProvider);

    // 検索テキストをプロバイダから取得
    final searchText = ref.read(searchTextProvider);

    // searchDefaultWidgetに戻るボタン
    final backIcon = IconButton(
      icon: const Icon(Icons.arrow_back),
      iconSize: 15,
      onPressed: () {
        // 検索結果がない状態に戻す
        ref.read(hasSearchResultProvider.notifier).state = false;
      },
    );

    // 検索結果のヘッダー
    final searchResultHeader = Container(
      width: double.infinity,
      height: 30,
      child: Row(
        children: [
          SizedBox(height: 30,child: backIcon,), 
          Text("「$searchText」の検索結果"),],
      )
    );

    // 検索結果のパネル
    final searchResultPanel = searchResult.when(
      data: (recipes) {
        if (recipes.isEmpty) {
          return const Center(child: Text("検索結果がありません"));
        }
        return Expanded(
          child: ListView.builder(
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              debugPrint('検索結果のレシピ: ${recipes[index].title}');
              final recipe = recipes[index];
              return ListItem(recipe: recipe);
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text("Error: $error")),
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center, // 左寄せに変更
      children: [
        searchResultHeader,
        const SizedBox(height: 20),
        searchResultPanel
      ],
    );
  }
}


class ListItem extends ConsumerWidget {
  const ListItem({super.key, required this.recipe});
  final Recipe recipe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final double rating = (recipe.reviewAverage.reccommend).toDouble();

    String? url;

    final path = recipe.imagePath;

    // ホストとポートの(画像生成時の環境による違いの)整合性をとる
    if(path != null){
      url = getUrl(storageHost, storagePort, path);
    }

    final item = ListTile(
      leading: url != null
        ? Image.network(ensureAltMediaParameter(url), width: tileImageSize, height: tileImageSize, fit: BoxFit.cover)
        : Image.asset("assets/images/noImage.png", width: tileImageSize, height: tileImageSize, fit: BoxFit.cover),
      title: Text(
        recipe.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis, // テキストが長い場合は省略
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            recipe.ingredients.keys.join(", "),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 8)
          ),
          const SizedBox(height: 2),
          // レビューがなければ「レビューなし」と表示 
          StarWidget(rating: rating)
        ],
      ),
      onTap: () {
        // レシピの詳細画面に遷移する処理を追加
        // レシピIDを状態管理に保存
        final recipeIdNotifier = ref.read(recipeIdProvider.notifier);
        recipeIdNotifier.state = recipe.id;
        // レシピの詳細画面に遷移
        final contentNotifier = ref.read(homeContentTypeProvider.notifier);
        contentNotifier.state = ContentType.recipe;
      },
    );
    
    final itemContainer = SizedBox(
      width: double.infinity,
      height: tileImageSize + 18, // 星表示分高さを少し増やす
      child: item
    );
    
    return Card(
      elevation: 4, // 影の強さ
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 5.0),
        child: itemContainer,
      ),
    );
  }
}

