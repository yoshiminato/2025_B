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
    
    debugPrint("addComment");
    //debugPrint(comment.toString());
    
    //Commentテーブルにコメント(comment)を保存
    await FirebaseFirestore.instance.collection('Comment').add(comment.toMap());



    return;
  }

  Future<List<Comment>> getCommentsByRecipeId(String recipeId) async {
    
    //debugPrint("getComments");
    //recipeIdのコメントがあるコメント配列をqueryに
    final query = await FirebaseFirestore.instance.collection('Comment').where('recipeId',isEqualTo: recipeId).get();

    //queryをComment型に変形
    List<Comment> comment = query.docs.map((doc){
      final data = doc.data() as Map<String,dynamic>;
      return Comment.fromMap(data);
    }).toList();

    //debugPrint("コメントは$comment");

    return comment;

  }

}