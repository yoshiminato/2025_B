import 'package:class_2025_b/models/recipe_model.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:class_2025_b/states/user_state.dart';
import 'package:class_2025_b/services/database_service.dart';
import 'package:class_2025_b/states/recipe_id_state.dart';
import 'package:class_2025_b/states/home_state.dart';

class SearchWidget extends HookWidget {
  
  SearchWidget({super.key});

  @override
  Widget build(BuildContext context) {

    // テキストのコントローラ
    final searchTextController = useTextEditingController();

    // テキストの状態管理
    final searchTextState = useState<String>("");

    // 検索結果有無による表示変更のための状態管理
    final hasSearchResult = useState<bool>(false);

    final searchResult = useState<List<Recipe>>([]);

    final searchTextField = TextField(
      controller: searchTextController,
      decoration: const InputDecoration(
        labelText: "検索キーワード",
        border: OutlineInputBorder(),
      ),
      onChanged: (value) {
        // テキストが変更されたら状態を更新
        searchTextState.value = value;
      },
      onSubmitted: (value) async {
        // 検索処理をsearchTextStateの値を使ってsearchResultに格納
        final dbService = DatabaseService();

        try{
          final results = await dbService.getKeywordRecipes(value);
          debugPrint("SearchWidget: 検索キーワード: $value");
          debugPrint("SearchWidget: 検索結果の数: ${results.length}");

          searchResult.value = results;

          hasSearchResult.value = true; // 検索結果があるかどうかのフラグを初期化
        } 
        catch (e) {
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
          child: hasSearchResult.value
          ?
          SearchResultWidget(searchResult: searchResult.value)
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

    return UsersRecipesWidget();
  }
}

class CarouselCard extends ConsumerWidget {
  final Recipe recipe;

  const CarouselCard({super.key, required this.recipe});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final imageContainer = SizedBox(
      width: 70,
      height: 70,
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

class UsersRecipesWidget extends HookConsumerWidget {
  const UsersRecipesWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final user = ref.watch(userProvider);

    final userId = (user!=null) ? user.uid : null;

    final dbService = DatabaseService();

    late final Widget content;

    if (userId == null) {
      content =  const Center(child: Text("ログインしていません"));
    }
    else{
      content = FutureBuilder<List<Recipe>>(
        future: dbService.getUsersRecipes(userId!),
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
            return const Center(child: Text("ユーザの作成したレシピが見つかりませんでした"));
          }
        },
      );
    }

    


    final userRecipesContainer = Container(
      padding: const EdgeInsets.all(16.0),
      width: double.infinity,
      height: 160,
      child: content
    );

    return Column(
      children: [
        Text("ユーザのレシピ一覧"),
        SizedBox(height: 20),
        userRecipesContainer,
      ],
    );
  }
}

class SearchResultWidget extends ConsumerWidget {
  const SearchResultWidget({super.key, required this.searchResult});

  final List<Recipe> searchResult;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center, // 左寄せに変更
      children: [
        const Text("検索結果"),
        const SizedBox(height: 20),
        Expanded(
          child: ListView.builder(
            itemCount: searchResult.length,
            itemBuilder: (context, index) {
              final recipe = searchResult[index];
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
        ),
      ],
    );
  }
}

