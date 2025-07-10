import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/material.dart';
import 'package:class_2025_b/services/function_service.dart';
import 'package:class_2025_b/services/database_service.dart';
import 'package:class_2025_b/services/storage_service.dart';
import 'package:class_2025_b/models/recipe_model.dart';
import 'package:class_2025_b/models/filter_model.dart';
import 'package:class_2025_b/models/review_model.dart';
import 'package:class_2025_b/states/user_state.dart';
import 'package:class_2025_b/states/custom_state.dart';

part 'generate_state.g.dart';

enum GenerateState {
  initial,
  generatingRecipe,
  generatingImage,
  storingImage,
  registeringRecipe, // データベース登録中
  error,
}

final buttonLabels = [
  '濃厚な', 'スパイシー', 'ジューシー',
  'さっぱり', 'こってり', '淡泊な',
  'クセになる', 'うま味', 'まろやか',
  'コク深い', '香ばしい', '素朴な',
];

const generationLimit = 3; // レシピ再生成の最大回数

@riverpod
class GenerateStateNotifier extends _$GenerateStateNotifier {
  @override
  GenerateState build() {
    return GenerateState.initial; // 初期状態はinitial
  }

  // 状態を更新するメソッド
  void updateState(GenerateState newState) {
    state = newState; // 新しい状態に更新
  }

  // 状態を初期状態にリセットするメソッド
  void reset() {
    state = GenerateState.initial; // 初期状態にリセット
  }

  Filter _genFilter(
    ValueNotifier<bool> usePantryOnly,
    ValueNotifier<List<bool>> buttonStates,
    ValueNotifier<double> budgetState,
    ValueNotifier<double> timeState,
    ValueNotifier<double> servingsState,
    ValueNotifier<String> searchKeywordState,
  ){

    final asyncCustomize = ref.read(customizeNotifierProvider);

    late final List<String> allergys;
    late final List<String> availableTools;
    
    // カスタマイズ設定がある場合は分量を上書き
    if (asyncCustomize.value != null) {
      allergys = asyncCustomize.value!.allergys;
      availableTools = asyncCustomize.value!.availableTools;
    }

    List<String> ingredients = searchKeywordState.value
      .split(RegExp(r'\s+')) // 半角・全角スペース、タブなどすべての空白で分割
      .map((keyword) => keyword.trim().toLowerCase())
      .where((keyword) => keyword.isNotEmpty)
      .toList();

    final Filter filter = Filter(
      usePantryOnly: usePantryOnly.value,
      ingredients: ingredients,
      attributes: buttonStates.value.asMap().entries
        .where((entry) => entry.value)
        .map((entry) => buttonLabels[entry.key])
        .toList(),
      budget: budgetState.value.toInt(),
      time: timeState.value.toInt(),
      servings: servingsState.value.toInt(),
      allergy: allergys,
      availableTools: availableTools
    );

    return filter;
  }

  Future<Recipe> _genRecipe(Filter filter) async {

    updateState(GenerateState.generatingRecipe); // レシピ生成状態に更新

    final dbService = DatabaseService();
    final functionService = FunctionService();

    int genCount = 0;
    final user = ref.read(userProvider);

    Recipe? recipe;

    try{
      List<Review> reviews = await dbService.getReviewsByUserId(user?.uid ?? "");
      //レビューに対するレシピIDを取得
      List<String> reviewsRecipesId = reviews.map((review) => review.recipeId).toList();
      //レビューに対するレシピ情報を取得
      List<Recipe> reviewsRecipes = [];

      for(String recipeId in reviewsRecipesId){
        final recipe = await dbService.getRecipeById(recipeId);
        if(recipe != null) {
          reviewsRecipes.add(recipe);
        }
      }

      // レシピ生成を試みる
      while (genCount < generationLimit && (recipe == null)) {
        try{
          debugPrint("レシピ生成中: 再生成カウント: ${genCount+1}");
          recipe = await functionService.generateRecipe(filter, reviews, reviewsRecipes);
        }
        catch (e) {
          if (genCount >= generationLimit) {
            throw Exception("$e");
          }
        } 
        finally {
          genCount++;
        }
      }
    }
    catch (e) {
      debugPrint("レシピ生成に失敗: $e");
      // エラー状態に更新
      updateState(GenerateState.error);
      throw Exception("レシピ生成に失敗しました: $e");
    }

    if (recipe == null) {
      updateState(GenerateState.error); // エラー状態に更新
      throw Exception("レシピ生成に失敗しました");
    }

    return recipe!;
  }

  // 画像生成を行うメソッド
  Future<String> _genImage(Recipe recipe) async {

    updateState(GenerateState.generatingImage); // 画像生成状態に更新

    final functionService = FunctionService();

    int genCount = 0; // 再生成カウント
    String? base64Image;

    // 画像生成を試みる
    while (genCount < generationLimit && (base64Image == null)) {
      try{
        debugPrint("レシピ画像生成中: 再生成カウント: ${genCount+1}");
        base64Image = await functionService.generateBase64Image(recipe); // レシピがnullでも画像生成は可能
      }
      catch (e) {
        debugPrint("画像生成に失敗: $e");
        if (genCount >= generationLimit) {
          throw Exception("画像生成に失敗しました: $e");
        }
      }
      finally{
        genCount++;
      }
    }

    if (base64Image == null) {
      updateState(GenerateState.error); // エラー状態に更新
      throw Exception("画像生成に失敗しました");
    }

    return base64Image!;
  }

  // 画像をストレージに保存するメソッド
  Future<String> _storeImage(String base64Image) async {

    updateState(GenerateState.storingImage); // 画像保存状態に更新

    final storageService = StorageService();
    try {
      final String? imageUrl = await storageService.storeBase64ImageAndGetUrl(base64Image, "recipe");
      if (imageUrl == null) {
        throw Exception("画像の保存に失敗しました");
      }
      return imageUrl;
    } 
    catch (e) {
      debugPrint("画像保存エラー: $e");
      throw Exception("画像の保存に失敗しました: $e");
    }
  }

  // レシピをデータベースに登録するメソッド
  Future<String> _registerRecipeToDB(Recipe recipe) async {

    updateState(GenerateState.registeringRecipe); // レシピ登録状態に更新

    final dbService = DatabaseService();

    final String? recipeId = await dbService.addRecipe(recipe);

    if (recipeId == null) {
      updateState(GenerateState.error); // エラー状態に更新
      throw Exception("レシピIDがnullです");
    }

    return recipeId;
  }

  // レシピを生成し、ストレージに保存、DBに登録してDB内でのIDを取得するメソッド
  Future<String> genAndStoreRecipe(
    ValueNotifier<bool> usePantryOnly,
    ValueNotifier<List<bool>> buttonStates,
    ValueNotifier<double> budgetState,
    ValueNotifier<double> timeState,
    ValueNotifier<double> servingsState,
    ValueNotifier<String> searchKeywordState,
    List<String> buttonLabels,
  ) async {

    // Filterオブジェクトの作成
    final Filter filter = _genFilter(
      usePantryOnly,
      buttonStates,
      budgetState,
      timeState,
      servingsState,
      searchKeywordState,
    );

    // 生成されたレシピを格納する変数
    Recipe recipe = await _genRecipe(filter);

    String base64Image = await _genImage(recipe);

    String imageUrl = await _storeImage(base64Image);

    recipe.imageUrl = imageUrl; // 生成された画像URLをレシピに設定

    String recipeId = await _registerRecipeToDB(recipe);

    return recipeId; // 生成されたレシピIDを返す
  }
}

