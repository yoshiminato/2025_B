import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:class_2025_b/models/recipe_model.dart';
import 'package:class_2025_b/states/recipe_id_state.dart';
import 'package:sqflite/sqflite.dart';
import 'package:class_2025_b/services/database_service.dart';
import 'package:class_2025_b/states/home_state.dart';

class SearchWidget extends HookConsumerWidget {
  const SearchWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final searchController = useTextEditingController();
    final hasResult = useState(false);
    final isLoading = useState(false);
    final searchResults = useState<List<Recipe>>([]);

    final dbService = DatabaseService();
    // 検索クエリの変更時に検索を実行

    return Column(
      children: [
        // 検索バー
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: "ユーザ名を入力",
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        searchController.clear();
                        hasResult.value = false;
                        searchResults.value = [];
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onSubmitted: (value) async{
              isLoading.value = true;
              hasResult.value = true;
              try {
                searchResults.value = await dbService.getUsersRecipes(value);
              } catch (e) {
                searchResults.value = [];
              } finally {
                isLoading.value = false;
              }
            },
          ),

        ),


        // 検索結果表示エリア
        Expanded(
          child: _buildSearchResults(
            hasResult: hasResult.value,
            isLoading: isLoading.value,
            searchResults: searchResults.value,
            searchQuery: searchController.text,
            ref: ref,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults({
    required bool hasResult,
    required bool isLoading,
    required List<Recipe> searchResults,
    required String searchQuery,
    required WidgetRef ref,
  }) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!hasResult) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              "材料や料理名を入力してレシピを検索",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    if (searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              "「$searchQuery」に一致するレシピが見つかりませんでした",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    // レシピリストの表示
    return ListView.builder(
      itemCount: searchResults.length,
      padding: const EdgeInsets.all(8.0),
      itemBuilder: (context, index) {
        final recipe = searchResults[index];
        return _buildRecipeItem(recipe, ref);
      },
    );
  }

  Widget _buildRecipeItem(Recipe recipe, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      elevation: 2,
      child: InkWell(
        onTap: () {
          if (recipe.id != null) {
            ref.read(recipeIdProvider.notifier).state = recipe.id!;
            // レシピの詳細画面に遷移
            final contentNotifier = ref.read(currentContentTypeProvider.notifier);
            contentNotifier.state = ContentType.recipe;

          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // レシピ画像
              _buildRecipeImage(recipe),
              const SizedBox(width: 16),
              
              // レシピ情報
              Expanded(
                child: _buildRecipeInfo(recipe),
              ),
              
              // 統計情報
              _buildRecipeStats(recipe),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecipeImage(Recipe recipe) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty
            ? Image.network(
                recipe.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildDefaultImage();
                },
              )
            : _buildDefaultImage(),
      ),
    );
  }

  Widget _buildDefaultImage() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.restaurant_menu,
        size: 40,
        color: Colors.grey[600],
      ),
    );
  }

  Widget _buildRecipeInfo(Recipe recipe) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // レシピタイトル
        Text(
          recipe.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        
        // レシピ説明
        Text(
          recipe.description,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        
        // 時間とコスト
        Row(
          children: [
            Icon(
              Icons.access_time,
              size: 16,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              recipe.time,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(width: 16),
            Icon(
              Icons.attach_money,
              size: 16,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              recipe.cost,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecipeStats(Recipe recipe) {
    return Column(
      children: [
        // いいね数
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.favorite,
              size: 16,
              color: Colors.red[400],
            ),
            const SizedBox(width: 4),
            Text(
              recipe.likeCount.toString(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        // レビュー数
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.rate_review,
              size: 16,
              color: Colors.blue[400],
            ),
            const SizedBox(width: 4),
            Text(
              recipe.reviewCount.toString(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}