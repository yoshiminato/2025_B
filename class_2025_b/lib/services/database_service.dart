import 'package:class_2025_b/models/recipe_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService{

  // 生成したレシピを追加するメソッド
  Future<String?> addRecipe(Recipe recipe) async {

    return Future.delayed(const Duration(seconds: 2), () => "sampleRecipeId");

    // try{
    //   // テーブルの取得
    //   CollectionReference recipes = FirebaseFirestore.instance.collection('recipes');

    //   // レシピをMap形式(Firestoreのデータ形式)に変換
    //   Map<String, dynamic> recipeData = recipe.toMap();

    //   // レシピを追加してDBにおけるIDを取得
    //   DocumentReference docRef = await recipes.add(recipeData);

    //   // 追加したレシピのIDを返す
    //   return docRef.id;   
      
    // }
    // catch (e) {
    //   // エラーが発生した場合はnullを返す
    //   return null;
    // }
  } 

  // レシピをIDで取得するメソッド
  Future<Recipe?> getRecipeById(String recipeId) async {
    return Future.delayed(const Duration(seconds: 2), () => sampleRecipe1);


    // try {
    //   // テーブルの取得
    //   CollectionReference recipes = FirebaseFirestore.instance.collection('recipes');

    //   // IDでレシピを取得
    //   DocumentSnapshot docSnapshot = await recipes.doc(recipeId).get();

    //   // レシピが存在する場合はRecipeオブジェクトを返す
    //   if (docSnapshot.exists) {
    //     return Recipe.fromMap(docSnapshot.data() as Map<String, dynamic>);
    //   } else {
    //     return null; // レシピが存在しない場合はnullを返す
    //   }
    // } catch (e) {
    //   // エラーが発生した場合はnullを返す
    //   return null;
    // }
  }

}