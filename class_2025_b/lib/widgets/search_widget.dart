import 'package:class_2025_b/models/recipe_model.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:class_2025_b/states/user_state.dart';
import 'package:class_2025_b/services/database_service.dart';

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
      onSubmitted: (value) {
        // 検索処理をsearchTextStateの値を使ってsearchResultに格納
        hasSearchResult.value = true; // 検索結果があるかどうかのフラグを初期化
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

class UsersRecipesWidget extends ConsumerWidget {
  const UsersRecipesWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final user = ref.watch(userProvider);

    final userId = (user!=null) ? user.uid : null;

    final dbService = DatabaseService();

    late final Widget content;

    // ログインしていない場合
    if(userId == null) {
      content = const Center(child: Text("ログインしていません"));
    } 
    // ログインしている場合
    else {
      final futureUsersRecipe = useFuture(dbService.getUsersRecipes(userId));
      
      if(futureUsersRecipe.connectionState == ConnectionState.waiting) {
        content = const Center(child: CircularProgressIndicator());
      } 
      else if(futureUsersRecipe.hasError) {
        content = Center(child: Text("Error: ${futureUsersRecipe.error}"));
      } 
      else if(futureUsersRecipe.hasData && futureUsersRecipe.data!.isNotEmpty) {
        final recipes = futureUsersRecipe.data!;
        content = ListView.builder(
          itemCount: recipes.length,
          itemBuilder: (context, index) {
            final recipe = recipes[index];
            // レシピのリスト表示部分　レイアウトは要検討
            return ListTile(
              title: Text(recipe.title),
              subtitle: Text(recipe.description),
            );
          },
        );
      } 
      else {
        content = const Center(child: Text("ユーザの作成したレシピが見つかりませんでした"));
      }
    }    
    return Column(
      children: [
        Text("ユーザのレシピ一覧"),
        SizedBox(height: 20),
        Expanded(child: content),
      ],
    );
  }
}

class SearchResultWidget extends StatelessWidget {
  const SearchResultWidget({super.key, required this.searchResult});

  final List<Recipe> searchResult;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("検索結果"),
    );
  }
}

