import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';

class Recipe{

  String? id;               // Firestore用のドキュメントID
  String title;             // レシピのタイトル
  String description;       // レシピの説明
  String? imageUrl;         // レシピの画像URL（Firebase StorageのURLなど）
  List<String> ingredients; // 材料のリスト
  List<String> steps;       // 調理手順のリスト
  DateTime? createdAt;      // 作成日時
  String? userId;           // 作成者のUID
  int reviwewCount;     // レビュー数（初期値は0）
  int likeCount;        // いいね数（初期値は0）
  


  Recipe({
    this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.ingredients,
    required this.steps,
    this.createdAt,
    this.userId,
    this.reviwewCount = 0,
    this.likeCount = 0,
  });

  
}

final sampleRecipe = Recipe(
  title: "Sample Recipe",
  description: "This is a sample recipe description.",
  imageUrl: "https://example.com/sample.jpg",
  ingredients: ["Ingredient 1", "Ingredient 2", "Ingredient 3"],
  steps: ["Step 1", "Step 2", "Step 3"],
  createdAt: DateTime.now(),
  userId: "sampleUserId",
  id: "sampleRecipeId",
  reviwewCount: 0,
  likeCount: 0,
);