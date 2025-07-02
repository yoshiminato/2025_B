import 'package:class_2025_b/models/recipe_model.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:class_2025_b/states/recipe_id_state.dart';
import 'package:class_2025_b/states/home_state.dart';
import 'package:class_2025_b/states/search_state.dart';
import 'package:class_2025_b/states/recent_recipes_state.dart';
import 'package:class_2025_b/states/favorite_recipes_state.dart';
import 'package:class_2025_b/states/user_recipe_state.dart';
import 'package:class_2025_b/states/history_recipe_id_state.dart';
import 'package:class_2025_b/states/search_sort_state.dart';

const imageSize = 70.0; // カルーセルカードの画像サイズ

class SearchScreen extends HookConsumerWidget {
  
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    // テキストのコントローラ
    final searchTextController = useTextEditingController(text: ref.read(searchTextProvider));

    // 検索結果の有無で画面更新
    final hasResult = ref.watch(hasSearchResultProvider);

    final searchTextField = TextField(
      controller: searchTextController,
      decoration: const InputDecoration(
        labelText: "検索キーワード",
        border: OutlineInputBorder(),
      ),

      
      /* テキストの変更をプロバイダに伝達 */
      onChanged: (value) {

        // プロバイダのNotifierを取得
        final searchTextNotifier = ref.read(searchTextProvider.notifier);

        // Notifierを使ってプロバイダの値を更新
        searchTextNotifier.state = value;

      },

      /* 検索文字列が提出されたら検索処理 */

      onSubmitted: (value) async {

        try{
          
          // 検索結果プロバイダのNotifierを取得
          final searchResultNotifier = ref.read(searchResultNotifierProvider.notifier);

          // 検索結果を有で更新
          ref.read(hasSearchResultProvider.notifier).state = true;

          // 検索処理
          await searchResultNotifier.updateSearchResult();

        } 
        catch (e) {

          // エラーが発生した場合はスナックバーで通知
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("検索中にエラーが発生しました: $e")),
          );

        }
      },
    );

    final searchTextFieldContainer = Container(
      padding: const EdgeInsets.all(16.0),
      width: double.infinity,
      height: 80,
      child: Row(
        children: [
          Expanded(child: searchTextField),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'ソート・フィルター',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (context) {
                  final sortType = ref.watch(sortStateProvider);
                  return SafeArea(
                    child: SingleChildScrollView(
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
                            RadioListTile<SortType>(
                              title: const Text('新しい順'),
                              value: SortType.newest,
                              groupValue: sortType,
                              onChanged: (value) {
                                if (value != null) {
                                  ref.read(sortStateProvider.notifier).state = value;
                                  Navigator.of(context).pop();
                                }
                              },
                            ),
                            RadioListTile<SortType>(
                              title: const Text('古い順'),
                              value: SortType.oldest,
                              groupValue: sortType,
                              onChanged: (value) {
                                if (value != null) {
                                  ref.read(sortStateProvider.notifier).state = value;
                                  Navigator.of(context).pop();
                                }
                              },
                            ),
                            RadioListTile<SortType>(
                              title: const Text('価格順'),
                              value: SortType.cost,
                              groupValue: sortType,
                              onChanged: (value) {
                                if (value != null) {
                                  ref.read(sortStateProvider.notifier).state = value;
                                  Navigator.of(context).pop();
                                }
                              },
                            ),
                            RadioListTile<SortType>(
                              title: const Text('調理時間順'),
                              value: SortType.time,
                              groupValue: sortType,
                              onChanged: (value) {
                                if (value != null) {
                                  ref.read(sortStateProvider.notifier).state = value;
                                  Navigator.of(context).pop();
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );




    // 検索ボックスとコンテンツを並べて返す
    return Column(
      children: [
        searchTextFieldContainer,
        // 検索結果がある場合はSearchResultWidgetを表示
        Expanded(
          child: hasResult
          ?
          SearchResultWidget()
          :
          DefaultSearchWidget(),
        ),
      ],
    );
  }
}

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
              margin: EdgeInsets.symmetric(horizontal: 8),
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

class DefaultSearchWidget extends ConsumerWidget {
  const DefaultSearchWidget({super.key});

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

class CarouselCard extends ConsumerWidget {
  final Recipe recipe;

  const CarouselCard({super.key, required this.recipe});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final imageContainer = SizedBox(
      width: imageSize,
      height: imageSize,
      child: recipe.imageUrl != null
          ? Image.network(recipe.imageUrl!, fit: BoxFit.cover)
          : Image.asset(
              "assets/images/noImage.png",
              fit: BoxFit.cover,
            ),
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

    return InkWell(
        onTap: () {
          // レシピの詳細画面に遷移する処理を追加
          final recipeIdNotifier = ref.read(recipeIdProvider.notifier);
          recipeIdNotifier.state = recipe.id;

          // レシピの詳細画面に遷移
          final contentNotifier = ref.read(currentContentTypeProvider.notifier);
          contentNotifier.state = ContentType.recipe;

        },
        child: Padding(
          padding: EdgeInsets.all(5.0),
          child: column,
        
        ),
      );

    // return Card(
      
    //   child: InkWell(
    //     onTap: () {
    //       // レシピの詳細画面に遷移する処理を追加
    //       final recipeIdNotifier = ref.read(recipeIdProvider.notifier);
    //       recipeIdNotifier.state = recipe.id;

    //       // レシピの詳細画面に遷移
    //       final contentNotifier = ref.read(currentContentTypeProvider.notifier);
    //       contentNotifier.state = ContentType.recipe;

    //     },
    //     child: Padding(
    //       padding: EdgeInsets.all(5.0),
    //       child: column,
        
    //     ),
    //   ),
      
    // );
  }
}

const tileImageSize = 70.0;

class SearchResultWidget extends ConsumerWidget {
  const SearchResultWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    // 検索結果をプロバイダから取得
    final searchResult = ref.watch(searchResultNotifierProvider);

    final searchText = ref.read(searchTextProvider);

    final backIcon = IconButton(
      icon: const Icon(Icons.arrow_back),
      iconSize: 15,
      onPressed: () {
        // 検索結果をクリア
        ref.read(searchResultNotifierProvider.notifier).clearSearchResult();
        // 検索テキストをクリア
        ref.read(searchTextProvider.notifier).state = "";
        // 検索結果がない状態に戻す
        ref.read(hasSearchResultProvider.notifier).state = false;
      },
    );

    final searchResultHeader = Container(
      width: double.infinity,
      height: 30,
      child: Row(
        children: [
          SizedBox(height: 30,child: backIcon,), 
          Text("「$searchText」の検索結果"),],
      )
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center, // 左寄せに変更
      children: [

        searchResultHeader,
        const SizedBox(height: 20),
        searchResult.when(
          data: (recipes) {
            if (recipes.isEmpty) {
              return const Center(child: Text("検索結果がありません"));
            }
            return Expanded(
              child: ListView.builder(
                itemCount: recipes.length,
                itemBuilder: (context, index) {
                  final recipe = recipes[index];
                  final tile = SizedBox(
                    width: double.infinity,
                    height: tileImageSize,
                    child: ListTile(
                      leading: recipe.imageUrl != null
                        ? Image.network(recipe.imageUrl!, width: tileImageSize, height: tileImageSize, fit: BoxFit.cover)
                        : Image.asset("assets/images/noImage.png", width: tileImageSize, height: tileImageSize, fit: BoxFit.cover),
                      title: Text(
                        recipe.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis, // テキストが長い場合は省略
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)
                      ),
                      subtitle: Text(
                        recipe.ingredients.keys.join(", "),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 8)

                      ), // 材料をカンマ区切りで表示
                      onTap: () {
                      
                        // レシピの詳細画面に遷移する処理を追加
                        // レシピIDを状態管理に保存
                        final recipeIdNotifier = ref.read(recipeIdProvider.notifier);
                        recipeIdNotifier.state = recipe.id;

                        // レシピの詳細画面に遷移
                        final contentNotifier = ref.read(currentContentTypeProvider.notifier);
                        contentNotifier.state = ContentType.recipe;
                      },
                    ),
                  );

                  return Card(
                    elevation: 4, // 影の強さ
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 5.0),
                      child: tile,
                    ),
                  );
                },
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text("Error: $error")),
        ),
        
      ],
    );
  }
}

