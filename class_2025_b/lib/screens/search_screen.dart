import 'package:class_2025_b/models/recipe_model.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:class_2025_b/states/user_state.dart';
import 'package:class_2025_b/services/database_service.dart';
import 'package:class_2025_b/states/recipe_id_state.dart';
import 'package:class_2025_b/states/home_state.dart';
import 'package:class_2025_b/states/search_state.dart';
import 'package:class_2025_b/states/favorite_recipe_id_state.dart';

const imageSize = 70.0; // カルーセルカードの画像サイズ

class SearchWidget extends HookConsumerWidget {
  
  const SearchWidget({super.key});

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
      child: searchTextField,
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

class DefaultSearchWidget extends ConsumerWidget {
  const DefaultSearchWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final column = Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center, // 左寄せに変更
      children: [
        RecentRecipesWidget(),
        const SizedBox(height: 20),
        FavoriteRecipesWidget(),
        const SizedBox(height: 20),
        UsersRecipesWidget(),
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
      children: [
        imageContainer,
        Text(
          recipe.title, 
          style: const TextStyle(fontSize: 9),
          overflow: TextOverflow.ellipsis,
          maxLines: 2, // 1行だけ表示
        ),
      ],
    );


    return Card(
      
      child: InkWell(
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
      ),
      
    );
  }
}


class RecentRecipesWidget extends HookConsumerWidget {
  const RecentRecipesWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    //ref.watch(); // ﾚｼﾋﾟ追加で自動更新されるよう設定する

    // DatabaseServiceのインスタンスを取得
    final dbService = DatabaseService();

    // 最近のレシピを取得
    final recentRecipes = dbService.getRecentRecipes();

    final content = FutureBuilder<List<Recipe>>(
      future: recentRecipes,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } 
        else if (snapshot.hasError) {
          return Center(child: Text("エラーが発生しました: ${snapshot.error}"));
        } 
        else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final recipes = snapshot.data!;
          return PageView.builder(
            controller: PageController(viewportFraction: 0.3),
            padEnds: false,
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              return Container(
                padding: const EdgeInsets.all(5.0),
                child: CarouselCard(recipe: recipe)
              );
            },
          );
        } 
        else {
          return const Center(child: Text("最近のレシピが見つかりませんでした"));
        }
      },
    );

    final recentRecipeHeader = Text("最近のレシピ一覧");
  
    final recentRecipesContainer = Container(
      padding: const EdgeInsets.all(16.0),
      width: double.infinity,
      height: 160,
      child: content
    );

    return Column(
      children: [
        recentRecipeHeader,
        SizedBox(height: 10),
        recentRecipesContainer,
      ],
    );
  }
}

class FavoriteRecipesWidget extends HookConsumerWidget {
  const FavoriteRecipesWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    // お気に入りのレシピの取得
    final favoriteRecipeIds = ref.watch(favoriteRecipeIdNotifierProvider);

    // コンテンツ部分(レシピ一覧, エラー、ローディングマーク)
    final content = favoriteRecipeIds.when(
      data: (recipeIds) {

        // お気に入りのレシピがない場合の処理
        if (recipeIds.isEmpty) {
          return const Center(child: Text("お気に入りのレシピが登録されていません"));
        }

        // お気に入りのレシピがある場合はカルーセルを表示
        return PageView.builder(
          controller: PageController(viewportFraction: 0.3),
          padEnds: false,
          itemCount: recipeIds.length,
          itemBuilder: (context, index) {
            final recipeId = recipeIds[index];
            final dbService = DatabaseService();
            return FutureBuilder<Recipe?>(
              future: dbService.getRecipeById(recipeId),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data == null) {
                  // レシピが見つからない場合は何も表示しない or プレースホルダー
                  return const SizedBox.shrink();
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } 
                else if (snapshot.hasError) {
                  return Center(child: Text("エラーが発生しました: ${snapshot.error}"));
                }
                final recipe = snapshot.data!;
                return Container(
                  padding: const EdgeInsets.all(5.0),
                  child: CarouselCard(recipe: recipe),
                );
              },
            );
          },
        );
      }, 
      error: (error, stack) => Text("エラーが発生しました: $error"), 
      loading: () => const Center(child: Text(""))
    );

    final favoriteRecipeHeader = Text("お気に入りレシピ一覧");
  
    final favoriteRecipesContainer = Container(
      padding: const EdgeInsets.all(16.0),
      width: double.infinity,
      height: 160,
      child: content
    );

    return Column(
      children: [
        favoriteRecipeHeader,
        SizedBox(height: 5),
        favoriteRecipesContainer,
      ],
    );
  }
}

class UsersRecipesWidget extends HookConsumerWidget {
  const UsersRecipesWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    // ユーザ情報を取得
    final user = ref.watch(userProvider);
    final userId = (user!=null) ? user.uid : null;

    // DatabaseServiceのインスタンスを取得
    final dbService = DatabaseService();

    late final Widget content;

    if (userId == null) {
      content =  const Center(child: Text("ログインしていません", style: TextStyle(fontSize: 10)));
    }
    else{
      content = FutureBuilder<List<Recipe>>(
        future: dbService.getUsersRecipes(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } 
          else if (snapshot.hasError) {
            if(snapshot.error.toString().contains('認証エラー')) {
              // 認証エラーの場合はログアウト処理を行う
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("認証エラー発生,自動ログアウトしました"),
                ),
              );
            }
            return Center(child: Text("Error: ${snapshot.error}"));
          } 
          else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final recipes = snapshot.data!;
            return PageView.builder(
              controller: PageController(viewportFraction: 0.3),
              padEnds: false,
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                final recipe = recipes[index];
                return Container(
                  padding: const EdgeInsets.all(5.0),
                  child: CarouselCard(recipe: recipe)
                );
              },
            );
          } 
          else {
            return const Center(child: Text("ユーザの作成したレシピが見つかりませんでした", style: TextStyle(fontSize: 10)));
          }
        },
      );
    }

    final userRecipeHeader = Text("ユーザの作成したレシピ一覧");
  
    final userRecipesContainer = Container(
      padding: const EdgeInsets.all(16.0),
      width: double.infinity,
      height: 160,
      child: content
    );

    return Column(
      children: [
        userRecipeHeader,
        SizedBox(height: 10),
        userRecipesContainer,
      ],
    );
  }
}

class SearchResultWidget extends ConsumerWidget {
  const SearchResultWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    // 検索結果をプロバイダから取得
    final searchResult = ref.watch(searchResultNotifierProvider);

    final searchText = ref.read(searchTextProvider);

    final backIcon = IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        // 検索結果をクリア
        ref.read(searchResultNotifierProvider.notifier).clearSearchResult();
        // 検索テキストをクリア
        ref.read(searchTextProvider.notifier).state = "";
        // 検索結果がない状態に戻す
        ref.read(hasSearchResultProvider.notifier).state = false;
      },
    );

    final searchResultHeader = Row(
      children: [backIcon, Text("「$searchText」の検索結果"),],
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
            return
            Expanded(
              child: ListView.builder(
                itemCount: recipes.length,
                itemBuilder: (context, index) {
                  final recipe = recipes[index];
                  return ListTile(
                    title: Text(recipe.title),
                    subtitle: Text(recipe.description),
                    onTap: () {
                    
                      // レシピの詳細画面に遷移する処理を追加
                      // レシピIDを状態管理に保存
                      final recipeIdNotifier = ref.read(recipeIdProvider.notifier);
                      recipeIdNotifier.state = recipe.id;

                      // レシピの詳細画面に遷移
                      final contentNotifier = ref.read(currentContentTypeProvider.notifier);
                      contentNotifier.state = ContentType.recipe;
                    },
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

