import 'dart:io' show Platform;

import 'package:class_2025_b/models/filter_model.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:class_2025_b/models/recipe_model.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FunctionService {

  late String basePath;

  void getBaseURL() {

    // basePath = "https://us-central1-recipe-ai-175b2.cloudfunctions.net";

    if (kIsWeb) {
      // Web(開発環境)の場合: localhost
      basePath = "http://localhost:5001/recipe-ai-175b2/us-central1";
      // Web(本番環境)の場合: 以下をコメントアウト解除
      // basePath = "https://us-central1-recipe-ai-175b2.cloudfunctions.net";
    } 
    else if( Platform.isAndroid ){
      // Android エミュレータの場合: 10.0.2.2 を使用
      basePath = "http://10.0.2.2:5001/recipe-ai-175b2/us-central1";
    }
    else {
      // iOS シミュレータやその他の場合: localhost
      basePath = "http://localhost:5001/recipe-ai-175b2/us-central1";
    }
  }

  Future<Recipe?> generateRecipe(Filter filter) async {
    getBaseURL();
    final prompt = '''
      あなたはプロの料理人です。以下の条件に基づいて、斬新なレシピを生成してください。
      条件:
      - 使用する食材: ${filter.ingredients.join(', ')}
      - 気分: ${filter.moods.entries.map((e) {
                if (e.value) { return e.key; } // trueの選択肢のみ表示
                else { return ''; }
      }).join(', ')}
      - 予算: ${filter.budget}
      - 調理時間: ${filter.time}
      - 何人分: ${filter.servings}
      - アレルギー: ${filter.allergy.join(', ')}
      - 使用可能な調理器具: ${filter.isToolAvailable.entries.map((e) {
                            if (e.value) { return e.key; } // trueの選択肢のみ表示
                            else { return ''; }
      }).join(', ')}
      レシピは以下の形式で出力してください:
      {
        "title": "レシピのタイトル",
        "description": "レシピの説明",
        "ingredients": {
          "材料名1": "分量1",
          "材料名2": "分量2"
        },
        "steps": [
          "調理手順1",
          "調理手順2"
        ],
        "time": "調理時間（分）",
        "cost": "予算（円）"
      }
      調理手順に手順番号は含めないでください
    ''';

    /* モックデータを返す処理(開発時のみ使用) */
    final responseText = '''
    {
      "title": "本格四川風麻婆豆腐",
      "description": "本場四川の味を再現した、豆板醤と花椒の効いた本格的な麻婆豆腐です。絹ごし豆腐の滑らかな食感と、香辛料の効いた深いコクのある味わいが楽しめます。ひき肉の旨味と豆腐の優しさが絶妙にマッチした、食欲をそそる一品です。",
      "ingredients": {
        "絹ごし豆腐": "400g",
        "豚ひき肉": "150g",
        "長ねぎ": "1本",
        "にんにく": "3片",
        "生姜": "1片",
        "豆板醤": "大さじ2",
        "甜麺醤": "大さじ1",
        "紹興酒": "大さじ2",
        "醤油": "大さじ2",
        "鶏がらスープの素": "小さじ1",
        "水": "200ml",
        "片栗粉": "大さじ1",
        "花椒": "小さじ1",
        "ごま油": "大さじ1",
        "サラダ油": "大さじ2"
      },
      "steps": [
        "豆腐を2cm角に切り、塩を入れた熱湯で2分茹でて水気を切る。",
        "長ねぎは白い部分を粗みじん切り、青い部分は小口切りにする。",
        "にんにくと生姜をそれぞれみじん切りにする。",
        "片栗粉を同量の水で溶いて水溶き片栗粉を作る。",
        "花椒をフライパンで乾煎りし、すり鉢で粗く砕く。",
        "中華鍋にサラダ油を熱し、豚ひき肉を中火で炒める。",
        "ひき肉がパラパラになったら、にんにくと生姜を加えて香りを出す。",
        "豆板醤を加えて30秒炒め、甜麺醤も加えてさらに炒める。",
        "紹興酒を加えてアルコールを飛ばし、醤油と鶏がらスープの素を入れる。",
        "水を加えて煮立たせ、豆腐を優しく加える。",
        "中火で3-4分煮込み、豆腐に味を染み込ませる。",
        "長ねぎの白い部分を加えて1分煮る。",
        "水溶き片栗粉を回し入れ、優しく混ぜてとろみをつける。",
        "火を止めて砕いた花椒とごま油を加えて混ぜる。",
        "器に盛り付け、長ねぎの青い部分を散らして完成。"
      ],
      "time": "45分",
      "cost": "650円"
    }
    ''';    

    final recipe = Recipe.fromJson(json.decode(responseText));     
    return Future.delayed(const Duration(seconds: 2), () => recipe);
      
    /* 実際にcloud functionを呼び出す場合 */
    // try{
    //   // cloud functionに登録した関数の呼び出し(開発段階ではそのままモックデータを返す)
    //   final requestBody = json.encode({
    //     "prompt": prompt
    //   });
      
    //   final res = await http.post(
    //     Uri.parse("$basePath/generateRecipe"),
    //     headers: {"Content-Type": "application/json"},
    //     body: requestBody
    //   );
      
    //   if (res.statusCode != 200) {
    //     throw Exception('HTTP Error ${res.statusCode}: ${res.body}');
    //   }
      
    //   if (res.body.isEmpty) {
    //     throw Exception('Empty response body');
    //   }
      
  //     try {
  //       final Recipe recipe = Recipe.fromJson(json.decode(res.body));
  //       return recipe;
  //     } 
  //     catch (e) {
  //       debugPrint("Recipe parsing error: $e");
  //       debugPrint("Response body was: ${res.body}");
  //       throw Exception('Failed to parse recipe: $e');
  //     }
  //   } 
  //   catch (e) {
  //     rethrow;
  //   }
  }

}
