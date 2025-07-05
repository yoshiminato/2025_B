

// レシピクラス
import 'package:class_2025_b/models/review_model.dart';

class Recipe{

  String? id;                      // Firestore用のドキュメントID
  String title;                    // レシピのタイトル
  String description;              // レシピの説明
  String? imageUrl;                // レシピの画像URL（Firebase StorageのURLなど）
  String? imageBase64;             // レシピの画像のBase64エンコードされた文字列（生成AIの出力受取用）
  Map<String, String> ingredients; // 材料のリスト
  List<String> steps;              // 調理手順のリスト {手順: 所要時間}
  String time;                     // 総所要時間
  String cost;                     // 予算（コスト）
  int servings;                    // 何人前か（例: 2人前）
  DateTime createdAt;              // 作成日時
  String? userId;                  // 作成者のUID
  int reviewCount;                 // レビュー数（初期値は0）
  ReviewAverage reviewAverage; // レビューの平均値

  Recipe({
    this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.ingredients,
    required this.steps,
    required this.time,
    required this.cost,
    this.servings = 1, // デフォルトは1人前
    required this.createdAt,
    this.userId,
    this.reviewCount = 0,
    ReviewAverage? reviewAverage,
  }) : reviewAverage = reviewAverage ?? ReviewAverage.empty;


  // RecipeオブジェクトをMapに変換（Firestore保存用）
  Map<String, dynamic> toMap() {
    // ingredientsMapを2つの配列に分けて保存
    List<String> ingredientNames = ingredients.keys.toList();
    List<String> ingredientAmounts = ingredients.values.toList();
    
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'ingredients': ingredients, // 従来のMap形式も保持（互換性のため）
      'ingredientNames': ingredientNames, // 検索用の材料名配列
      'ingredientAmounts': ingredientAmounts, // 分量配列
      'steps': steps,
      'time': time,
      'cost': cost,
      'servings': servings,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'userId': userId,
      'reviewCount': reviewCount,
    };
  }  // MapからRecipeオブジェクトを作成（Firestore読み込み用）
  factory Recipe.fromMap(Map<String, dynamic> map) {
    Map<String, String> ingredients = {};
    
    // 新しい形式（ingredientNames + ingredientAmounts）がある場合
    if (map.containsKey('ingredientNames') && map.containsKey('ingredientAmounts')) {
      List<String> names = List<String>.from((map['ingredientNames'] as List?) ?? []);
      List<String> amounts = List<String>.from((map['ingredientAmounts'] as List?) ?? []);
      
      // 2つの配列を組み合わせてMapを作成
      for (int i = 0; i < names.length && i < amounts.length; i++) {
        ingredients[names[i]] = amounts[i];
      }
    } 
    // 従来の形式（ingredients Map）がある場合（後方互換性）
    else if (map.containsKey('ingredients')) {
      ingredients = Map<String, String>.from((map['ingredients'] as Map?) ?? {});
    }
    
    return Recipe(
      id: map['id'] as String?,
      title: (map['title'] as String?) ?? '',
      description: (map['description'] as String?) ?? '',
      imageUrl: map['imageUrl'] as String?,
      ingredients: ingredients,
      steps: List<String>.from((map['steps'] as List?) ?? []),
      time: (map['time'] as String?) ?? '',
      cost: (map['cost'] as String?) ?? '',
      servings: (map['servings'] as int?) ?? 1, // デフォルトは1人前
      createdAt: map['createdAt'] != null 
        ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int)
        : DateTime.now(),
      userId: map['userId'] as String?,
      reviewCount: (map['reviewCount'] as int?) ?? 0,
    );
  }
  // RecipeオブジェクトをJSONに変換（API用）?? ユーザの評価履歴をもとにプロンプトするなら使うかも
  Map<String, dynamic> toJson() {
    // ingredientsMapを2つの配列に分けて保存
    List<String> ingredientNames = ingredients.keys.toList();
    List<String> ingredientAmounts = ingredients.values.toList();
    
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'ingredients': ingredients, // 従来のMap形式も保持（互換性のため）
      'ingredientNames': ingredientNames, // 検索用の材料名配列
      'ingredientAmounts': ingredientAmounts, // 分量配列
      'steps': steps,
      'time': time,
      'cost': cost,
      'servings': servings,
      'createdAt': createdAt.toIso8601String(),
      'userId': userId,
      'reviewCount': reviewCount,
    };
  }
  // JSONからRecipeオブジェクトを作成（API用）
  factory Recipe.fromJson(Map<String, dynamic> json) {
    Map<String, String> ingredients = {};
    
    // 新しい形式（ingredientNames + ingredientAmounts）がある場合
    if (json.containsKey('ingredientNames') && json.containsKey('ingredientAmounts')) {
      List<String> names = List<String>.from(json['ingredientNames'] as List);
      List<String> amounts = List<String>.from(json['ingredientAmounts'] as List);
      
      // 2つの配列を組み合わせてMapを作成
      for (int i = 0; i < names.length && i < amounts.length; i++) {
        ingredients[names[i]] = amounts[i];
      }
    } 
    // 従来の形式（ingredients Map）がある場合（後方互換性）
    else if (json.containsKey('ingredients')) {
      ingredients = Map<String, String>.from(json['ingredients'] as Map);
    }
    
    return Recipe(
      id: json['id'] as String?,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String?,
      ingredients: ingredients,
      steps: List<String>.from(json['steps'] as List),
      time: json['time'] as String,
      cost: json['cost'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      userId: json['userId'] as String?,
      reviewCount: json['reviewCount'] as int? ?? 0,
    );
  }

}
