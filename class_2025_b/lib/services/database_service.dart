import 'package:class_2025_b/models/recipe_model.dart';
import 'package:class_2025_b/models/comment_model.dart';
import 'package:class_2025_b/models/review_model.dart';
import 'package:class_2025_b/states/search_sort_state.dart';
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

  Future<void> addReview(String userId, String recipeId, Review review) async {

    debugPrint("addReview");

    try {
      // レビューコレクションの入手
      final reviewsRef = FirebaseFirestore.instance.collection('Review');

      // 既存レビューの有無を確認
      final querySnapshot = await reviewsRef
          .where('recipeId', isEqualTo: recipeId)
          .where('userId', isEqualTo: userId)
          .get();

      // 既存レビューがあれば更新
      if (querySnapshot.docs.isNotEmpty) {
        
        final docId = querySnapshot.docs.first.id;
        await reviewsRef.doc(docId).update(review.toMap(userId, recipeId));
     
      } 
      // なければ新規追加
      else {
        await reviewsRef.add(review.toMap(userId, recipeId));
        debugPrint("新規レビューを追加しました");
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
      return;
    }
  }

  Future<Review> getReviewByRecipeIdAndUserId(String userId, String recipeId) async {

    debugPrint("getReviewByRecipeId");

    try {
      // レビューコレクションの取得
      final reviewsRef = FirebaseFirestore.instance.collection('Review');

      // レシピID, ユーザーIDでレビューを取得
      final querySnapshot = await reviewsRef
          .where('recipeId', isEqualTo: recipeId)
          .where('userId', isEqualTo: userId)
          .get();

      if(querySnapshot.docs.length > 1) {
        debugPrint("１つのレシピに対して複数のレビューがなされています");
        throw Exception("複数のレビューが存在します: ${querySnapshot.docs.length}");
      }

      if (querySnapshot.docs.isEmpty) {
        return Review.empty; // デフォルト値を返す
      }

      final reveiwMap = querySnapshot.docs.first.data();
      return Review.fromMap(reveiwMap);

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
      throw Exception("エラー発生:$e"); // エラー時もデフォルト値を返す
    }
  }

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
  Future<List<Recipe>> getKeywordRecipes(String keywords, SortType type) async {

    debugPrint("SortType: $type");

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
      bool sort_tmp = false; // デフォルトは昇順
      String sort_name = "createdAt"; // デフォルトのソートフィールド

      //typeがnewestの場合はcreatedAtで降順、oldestの場合はcreatedAtで昇順、それ以外はtypeの値をそのまま使用して昇順
      if(type == SortType.newest){
        sort_tmp = true;
        sort_name = "createdAt";

      }else if(type == SortType.oldest){
        sort_tmp = false;
        sort_name = "createdAt";
        
      }else{
        sort_tmp = false;
        sort_name = "$type";
      }

      final recipesRef = FirebaseFirestore.instance.collection('recipes');
      final query = await recipesRef.where('ingredientNames', arrayContainsAny: keywordsList).orderBy(sort_name, descending: sort_tmp).get();

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
