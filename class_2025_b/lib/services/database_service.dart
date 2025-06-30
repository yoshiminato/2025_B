import 'package:class_2025_b/models/recipe_model.dart';
import 'package:class_2025_b/models/comment_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';


class DatabaseService{

  final String recipeCollectionPath = 'recipes';

  final int limit = 10; // レシピの取得数の制限

  // 生成したレシピを追加するメソッド
  Future<String?> addRecipe(Recipe recipe) async {

    try{

      debugPrint("レシピをデータベースに追加します");

      // テーブルの取得
      CollectionReference recipesRef = FirebaseFirestore.instance.collection(recipeCollectionPath);

      // レシピをMap形式(Firestoreのデータ形式)に変換
      Map<String, dynamic> recipeData = recipe.toMap();
      
      debugPrint("レシピデータ変換完了: ${recipeData.keys.toList()}");

      // レシピを追加してDBにおけるIDを取得
      DocumentReference docRef = await recipesRef.add(recipeData);

      debugPrint("レシピ追加完了: ${docRef.id}");

      // 追加したレシピのIDを返す
      return docRef.id;   

    }
    catch (e) {
      // 認証エラーの場合の特別な処理
      if (e.toString().contains('UNAUTHENTICATED') || 
          e.toString().contains('INVALID_REFRESH_TOKEN')) {
        debugPrint("認証エラーが発生しました。再ログインが必要です: ${e.toString()}");
        // FirebaseAuthからログアウト
        try {
          await FirebaseAuth.instance.signOut();
          debugPrint("自動ログアウトを実行しました");
        } catch (signOutError) {
          debugPrint("ログアウトエラー: $signOutError");
        }
        throw Exception('認証エラー: 再ログインしてください');
      }
      
      // その他のエラーの場合
      debugPrint("データベースエラー: ${e.toString()}");
      debugPrint("エラータイプ: ${e.runtimeType}");
      return null;
    }
  }

  // レシピをIDで取得するメソッド
  Future<Recipe?> getRecipeById(String recipeId) async {

    try {
      // テーブルの取得

      CollectionReference recipesRef = FirebaseFirestore.instance.collection(recipeCollectionPath);


      // IDでレシピを取得
      DocumentSnapshot docSnapshot = await recipesRef.doc(recipeId).get();

      // レシピが存在する場合はRecipeオブジェクトを返す
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        
        // FirestoreのドキュメントIDを明示的に設定
        data['id'] = docSnapshot.id;
        
        return Recipe.fromMap(data);
      } else {
        return null; // レシピが存在しない場合はnullを返す
      }
    } catch (e) {

      // 認証エラーの場合の特別な処理
      if (e.toString().contains('UNAUTHENTICATED') || 
          e.toString().contains('INVALID_REFRESH_TOKEN')) {
        debugPrint("認証エラーが発生しました。再ログインが必要です: ${e.toString()}");
        // FirebaseAuthからログアウト
        try {
          await FirebaseAuth.instance.signOut();
          debugPrint("自動ログアウトを実行しました");
        } catch (signOutError) {
          debugPrint("ログアウトエラー: $signOutError");
        }
        throw Exception('認証エラー: 再ログインしてください');
      }

      // エラーが発生した場合はnullを返す
      return null;
    }
  }

  Future<void> addComment(Comment comment) async {
    
    debugPrint("addComment");
    try{
      //Commentテーブルにコメント(comment)を保存
      await FirebaseFirestore.instance.collection('Comment').add(comment.toMap());
    }
    catch (e) {
      // 認証エラーの場合の特別な処理
      if (e.toString().contains('UNAUTHENTICATED') || 
          e.toString().contains('INVALID_REFRESH_TOKEN')) {
        debugPrint("認証エラーが発生しました。再ログインが必要です: ${e.toString()}");
        // FirebaseAuthからログアウト
        try {
          await FirebaseAuth.instance.signOut();
          debugPrint("自動ログアウトを実行しました");
        } catch (signOutError) {
          debugPrint("ログアウトエラー: $signOutError");
        }
        throw Exception('認証エラー: 再ログインしてください');
      }
    }
    return;
  }

  Future<List<Comment>> getCommentsByRecipeId(String recipeId) async {
    
    debugPrint("getComments");

    try{
      final query = await FirebaseFirestore.instance.collection('Comment').where('recipeId',isEqualTo: recipeId).get();

      //queryをComment型に変形
      List<Comment> comment = query.docs.map((doc){
        final data = doc.data() as Map<String,dynamic>;
        return Comment.fromMap(data);
      }).toList();

      debugPrint("コメントは$comment");

      return comment;
    }
    catch (e) {
      // 認証エラーの場合の特別な処理
      if (e.toString().contains('UNAUTHENTICATED') || 
          e.toString().contains('INVALID_REFRESH_TOKEN')) {
        debugPrint("認証エラーが発生しました。再ログインが必要です: ${e.toString()}");
        // FirebaseAuthからログアウト
        try {
          await FirebaseAuth.instance.signOut();
          debugPrint("自動ログアウトを実行しました");
        } catch (signOutError) {
          debugPrint("ログアウトエラー: $signOutError");
        }
        throw Exception('認証エラー: 再ログインしてください');
      }

      return [];
    }
    

  }

  // // データベースに登録されているすべてのレシピを削除
  // Future<void> clearRecipes() async {
  //   final collection = FirebaseFirestore.instance.collection(recipeCollectionPath);
  //   final snapshots = await collection.get();

  //   for (final doc in snapshots.docs) {
  //     await doc.reference.delete();
  //   }
  // }

  // Future<void> addMockRecipes() async {
  //   // モックレシピを追加する処理を実装
  //   final recipes = sampleRecipesForTest;
  //   for (final recipe in recipes) {
  //     await addRecipe(recipe);
  //   }
  // }

  // 引数で受け取ったユーザIDをもとにユーザのレシピを取得するメソッド
  Future<List<Recipe>> getUsersRecipes(String userId) async {

    try{
      //データベースからuserIdと一緒のものをqueryに代入
      final query = await FirebaseFirestore.instance.collection(recipeCollectionPath).where('userId',isEqualTo:userId).orderBy("createdAt", descending: true).get();

      //queryをrecipe型に直してrecipesに代入
      List<Recipe> recipes = query.docs.map((doc){
        final data = doc.data();

        // FirestoreのドキュメントIDを明示的に設定
        data['id'] = doc.id;

        return Recipe.fromMap(data);
      }).toList();

      //条件に合うrecipesをかえす
      return recipes;
    }
    catch(e){
      // 認証エラーの場合の特別な処理
      if (e.toString().contains('UNAUTHENTICATED') || 
          e.toString().contains('INVALID_REFRESH_TOKEN')) {
        debugPrint("認証エラーが発生しました。再ログインが必要です: ${e.toString()}");
        // FirebaseAuthからログアウト
        try {
          await FirebaseAuth.instance.signOut();
          debugPrint("自動ログアウトを実行しました");
        } catch (signOutError) {
          debugPrint("ログアウトエラー: $signOutError");
        }
        throw Exception('認証エラー: 再ログインしてください');
      }
      return [];
    }
    
  } 

  // キーワードに一致するレシピを取得するメソッド
  Future<List<Recipe>> getKeywordRecipes(String keywords) async {
    try {
      List<String> keywordsList = keywords
        .split(RegExp(r'\s+')) // 半角・全角スペース、タブなどすべての空白で分割
        .map((keyword) => keyword.trim().toLowerCase())
        .where((keyword) => keyword.isNotEmpty)
        .toList();
      
      for (var keyword in keywordsList) {
        debugPrint("キーワード: $keyword");
      }
      

      // 新しい構造のingredientNamesフィールドで検索
      final recipesRef = FirebaseFirestore.instance.collection('recipes');
      final query = await recipesRef.where('ingredientNames', arrayContainsAny: keywordsList).orderBy("createdAt", descending: true).get();

      List<Recipe> recipes = query.docs.map((doc) {
        final data = doc.data();
        
        // FirestoreのドキュメントIDを明示的に設定
        data['id'] = doc.id;
        
        return Recipe.fromMap(data);
      }).toList();

      return recipes;
      
    } 
    catch (e) {

      if (e.toString().contains('UNAUTHENTICATED') || 
          e.toString().contains('INVALID_REFRESH_TOKEN')) {
        debugPrint("認証エラーが発生しました。再ログインが必要です: ${e.toString()}");
        // FirebaseAuthからログアウト
        try {
          await FirebaseAuth.instance.signOut();
          debugPrint("自動ログアウトを実行しました");
        } catch (signOutError) {
          debugPrint("ログアウトエラー: $signOutError");
        }
        throw Exception('認証エラー: 再ログインしてください');
      }

      return [];
    }
  }

  // // 部分一致検索のためのフォールバックメソッド
  // // arrayContainsAnyは完全一致のみなので、部分一致が必要な場合はこちらを使用
  // Future<List<Recipe>> getKeywordRecipesPartialMatch(String keywords) async {
  //   try {
  //     List<String> keywordsList = keywords.split(' ').map((keyword) => keyword.trim().toLowerCase()).toList();

  //     // 全てのレシピを取得してクライアント側でフィルタリング
  //     final recipesRef = FirebaseFirestore.instance.collection('recipes');
  //     final allRecipesQuery = await recipesRef.get();

  //     List<Recipe> matchedRecipes = [];

  //     for (var doc in allRecipesQuery.docs) {
  //       final data = doc.data();
  //       final recipe = Recipe.fromMap(data);
        
  //       // ingredientNamesフィールドがある場合はそれを使用、なければingredientsのキーを使用
  //       List<String> ingredientNames = [];
  //       if (data.containsKey('ingredientNames')) {
  //         ingredientNames = List<String>.from(data['ingredientNames'] as List);
  //       } else {
  //         ingredientNames = recipe.ingredients.keys.toList();
  //       }
        
  //       // 材料名を小文字に変換
  //       final lowerIngredients = ingredientNames.map((name) => name.toLowerCase()).toList();
        
  //       // キーワードのいずれかが材料名に含まれているかチェック（部分一致）
  //       bool hasMatchingIngredient = keywordsList.any((keyword) {
  //         return lowerIngredients.any((ingredient) => ingredient.contains(keyword));
  //       });

  //       if (hasMatchingIngredient) {
  //         matchedRecipes.add(recipe);
  //       }
  //     }

  //     return matchedRecipes;
      
  //   } catch (e) {
  //     print("Error in getKeywordRecipesPartialMatch: $e");
  //     return [];
  //   }
  // }

  /// imageUrlがnullのレシピをすべて削除する
  Future<void> deleteInvalidData() async {
    try {
      debugPrint("deleteInvalidData: imageUrlがnullのレシピを削除します");
      final collection = FirebaseFirestore.instance.collection(recipeCollectionPath);
      final querySnapshot = await collection.where('imageUrl', isNull: true).get();

      for (final doc in querySnapshot.docs) {
        await doc.reference.delete();
        debugPrint("削除: ${doc.id}");
      }
      debugPrint("deleteInvalidData: 完了");
    } catch (e) {
      debugPrint("deleteInvalidData エラー: ${e.toString()}");
      // 認証エラーの場合の特別な処理
      if (e.toString().contains('UNAUTHENTICATED') ||
          e.toString().contains('INVALID_REFRESH_TOKEN')) {
        try {
          await FirebaseAuth.instance.signOut();
          debugPrint("自動ログアウトを実行しました");
        } catch (signOutError) {
          debugPrint("ログアウトエラー: $signOutError");
        }
        throw Exception('認証エラー: 再ログインしてください');
      }
    }
  }

  Future<List<Recipe>> getRecentRecipes() async {
    try {
      final recipesRef = FirebaseFirestore.instance.collection(recipeCollectionPath);
      final querySnapshot = await recipesRef.orderBy("createdAt", descending: true).limit(limit).get();

      List<Recipe> recipes = querySnapshot.docs.map((doc) {
        final data = doc.data();
        
        // FirestoreのドキュメントIDを明示的に設定
        data['id'] = doc.id;
        
        return Recipe.fromMap(data);
      }).toList();

      return recipes;
    } catch (e) {
      debugPrint("getAllRecipes エラー: ${e.toString()}");
      // 認証エラーの場合の特別な処理
      if (e.toString().contains('UNAUTHENTICATED') ||
          e.toString().contains('INVALID_REFRESH_TOKEN')) {
        try {
          await FirebaseAuth.instance.signOut();
          debugPrint("自動ログアウトを実行しました");
        } catch (signOutError) {
          debugPrint("ログアウトエラー: $signOutError");
        }
        throw Exception('認証エラー: 再ログインしてください');
      }
      return [];
    }
  }

}


  




// テスト用のユーザデータ
final testUsers = [
  "User1",
  "User2",
  "User3",
];

// テスト用のレシピデータ
final sampleRecipeForTest1 = Recipe(
  title: "Sample Recipe 1",
  description: "This is a sample recipe description.",
  imageUrl: "https://example.com/sample.jpg",
  ingredients: {"Ingredient 1": "1 cup", "Ingredient 2": "2 tbsp", "Ingredient 3": "3 tsp"},
  steps: ["Step 1", "Step 2", "Step 3"],
  time: "30分",
  cost: "1000円",
  createdAt: DateTime.now(),
  userId: "User1",
  id: "sampleRecipeId",
  reviewCount: 0,
  likeCount: 0,
);

final sampleRecipeForTest2 = Recipe(
  title: "Sample Recipe 2",
  description: "This is another sample recipe description.",
  imageUrl: "https://example.com/sample2.jpg",
  ingredients: {"Ingredient A": "2 cups", "Ingredient B": "1 tbsp"},
  steps: ["Step A", "Step B"],
  time: "45分",
  cost: "1500円",
  createdAt: DateTime.now(),
  userId: "User2",
  id: "sampleRecipeId2",
  reviewCount: 0,
  likeCount: 0,
);

final sampleRecipeForTest3 = Recipe(
  title: "Sample Recipe 3",
  description: "This is yet another sample recipe description.",
  imageUrl: "https://example.com/sample3.jpg",
  ingredients: {"Ingredient X": "1 cup", "Ingredient Y": "2 tsp"},
  steps: ["Step X", "Step Y"],
  time: "20分",
  cost: "800円",
  createdAt: DateTime.now(),
  userId: "User3",
  id: "sampleRecipeId3",
  reviewCount: 0,
  likeCount: 0,
);

final sampleRecipeForTest4 = Recipe(
  title: "Sample Recipe 4",
  description: "This is a sample recipe for testing.",
  imageUrl: "https://example.com/sample4.jpg",
  ingredients: {"Ingredient M": "1 cup", "Ingredient N": "3 tbsp"},
  steps: ["Step M", "Step N"],
  time: "15分",
  cost: "500円",
  createdAt: DateTime.now(),
  userId: "User1",
  id: "sampleRecipeId4",
  reviewCount: 0,
  likeCount: 0,
);

final sampleRecipeForTest5 = Recipe(
  title: "Sample Recipe 5",
  description: "This is a sample recipe for testing.",
  imageUrl: "https://example.com/sample5.jpg",
  ingredients: {"Ingredient P": "2 cups", "Ingredient Q": "1 tbsp"},
  steps: ["Step P", "Step Q"],
  time: "10分",
  cost: "300円",
  createdAt: DateTime.now(),
  userId: "User2",
  id: "sampleRecipeId5",
  reviewCount: 0,
  likeCount: 0,
);

final sampleRecipeForTest6 = Recipe(
  title: "Sample Recipe 6",
  description: "This is a sample recipe description.",
  imageUrl: "https://example.com/sample.jpg",
  ingredients: {"Ingredient 1": "1 cup", "Ingredient 2": "2 tbsp", "Ingredient 3": "3 tsp"},
  steps: ["Step 1", "Step 2", "Step 3"],
  time: "30分",
  cost: "1000円",
  createdAt: DateTime.now(),
  userId: "User1",
  id: "sampleRecipeId1",
  reviewCount: 0,
  likeCount: 0,
);

// テスト用のレシピリスト
final sampleRecipesForTest = [
  sampleRecipeForTest1,
  sampleRecipeForTest2,
  sampleRecipeForTest3,
  sampleRecipeForTest4,
  sampleRecipeForTest5,
  sampleRecipeForTest6,
];