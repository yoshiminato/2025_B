import 'package:class_2025_b/models/recipe_model.dart';
import 'package:class_2025_b/models/comment_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class DatabaseService{
  // 生成したレシピを追加するメソッド
  Future<String?> addRecipe(Recipe recipe) async {

    try{

      debugPrint("レシピをデータベースに追加します");

      // テーブルの取得
      CollectionReference recipes = FirebaseFirestore.instance.collection('recipes');

      // レシピをMap形式(Firestoreのデータ形式)に変換
      Map<String, dynamic> recipeData = recipe.toMap();
      
      debugPrint("レシピデータ変換完了: ${recipeData.keys.toList()}");

      // レシピを追加してDBにおけるIDを取得
      DocumentReference docRef = await recipes.add(recipeData);

      debugPrint("レシピ追加完了: ${docRef.id}");

      // 追加したレシピのIDを返す
      return docRef.id;   
      
    }
    catch (e) {
      // エラーが発生した場合はnullを返す
      debugPrint("データベースエラー: ${e.toString()}");
      debugPrint("エラータイプ: ${e.runtimeType}");
      return null;
    }
  }

  // レシピをIDで取得するメソッド
  Future<Recipe?> getRecipeById(String recipeId) async {

    try {
      // テーブルの取得
      CollectionReference recipes = FirebaseFirestore.instance.collection('recipes');

      // IDでレシピを取得
      DocumentSnapshot docSnapshot = await recipes.doc(recipeId).get();


      // レシピが存在する場合はRecipeオブジェクトを返す
      if (docSnapshot.exists) {
        return Recipe.fromMap(docSnapshot.data() as Map<String, dynamic>);
      } else {
        return null; // レシピが存在しない場合はnullを返す
      }
    } catch (e) {
      // エラーが発生した場合はnullを返す
      return null;
    }
  }

  Future<void> addComment(Comment comment) async {
    
    // コメントをデータベースに追加する処理を実装

    return;
  }

  Future<List<Comment>> getComments(String recipeId) async {
    
    // コメントのデータベース取得処理を実装

    return [
      Comment(
        id: "sample_id",
        recipeId: "sample_recipe_id",
        userId: "sample_user_id",
        content: "サンプルコメント",
        timestamp: DateTime.now(),
        imageUrl: "https://picsum.photos/300/200"
      )
    ];
  }

}