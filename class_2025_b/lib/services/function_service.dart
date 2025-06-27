import 'dart:io' show Platform;
import 'dart:convert';
import 'dart:typed_data';

import 'package:class_2025_b/models/filter_model.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:class_2025_b/models/recipe_model.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

class FunctionService {

  late String basePath;

  void getBaseURL() {

    // basePath = "https://us-central1-recipe-ai-175b2.cloudfunctions.net";

    debugPrint("FunctionService: getBaseURL()");

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

    debugPrint("FunctionService: basePath = $basePath");
  }

  Future<Recipe?> generateRecipe(Filter filter) async {

    debugPrint("関数呼び出し: generateRecipe");

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
      レシピは以下のJSON形式で出力してください:
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
      また、作成するレシピの完成品を俯瞰で見たときのイラストを生成し、base64エンコードした画像データを返してください。
      最後に注意事項をまとめます
      - レシピは日本語で記述してください
      - レシピは必ず上に示した通りのJSON形式で出力してください
      - レスポンスのテキスト部分には'{}'で始まり'}'で終わるJSON部分以外のテキストは含めないでください
      - 調理手順の文字列に手順番号は含めないでください
      - 調理時間や予算には単位も含めて出力してください, ただし予算の単位は円としてください
    ''';    

    // /* モックデータを返す処理(開発時のみ使用) */
    // final responseText = '''
    // {
    //   "title": "本格四川風麻婆豆腐",
    //   "description": "本場四川の味を再現した、豆板醤と花椒の効いた本格的な麻婆豆腐です。絹ごし豆腐の滑らかな食感と、香辛料の効いた深いコクのある味わいが楽しめます。ひき肉の旨味と豆腐の優しさが絶妙にマッチした、食欲をそそる一品です。",
    //   "ingredients": {
    //     "絹ごし豆腐": "400g",
    //     "豚ひき肉": "150g",
    //     "長ねぎ": "1本",
    //     "にんにく": "3片",
    //     "生姜": "1片",
    //     "豆板醤": "大さじ2",
    //     "甜麺醤": "大さじ1",
    //     "紹興酒": "大さじ2",
    //     "醤油": "大さじ2",
    //     "鶏がらスープの素": "小さじ1",
    //     "水": "200ml",
    //     "片栗粉": "大さじ1",
    //     "花椒": "小さじ1",
    //     "ごま油": "大さじ1",
    //     "サラダ油": "大さじ2"
    //   },
    //   "steps": [
    //     "豆腐を2cm角に切り、塩を入れた熱湯で2分茹でて水気を切る。",
    //     "長ねぎは白い部分を粗みじん切り、青い部分は小口切りにする。",
    //     "にんにくと生姜をそれぞれみじん切りにする。",
    //     "片栗粉を同量の水で溶いて水溶き片栗粉を作る。",
    //     "花椒をフライパンで乾煎りし、すり鉢で粗く砕く。",
    //     "中華鍋にサラダ油を熱し、豚ひき肉を中火で炒める。",
    //     "ひき肉がパラパラになったら、にんにくと生姜を加えて香りを出す。",
    //     "豆板醤を加えて30秒炒め、甜麺醤も加えてさらに炒める。",
    //     "紹興酒を加えてアルコールを飛ばし、醤油と鶏がらスープの素を入れる。",
    //     "水を加えて煮立たせ、豆腐を優しく加える。",
    //     "中火で3-4分煮込み、豆腐に味を染み込ませる。",
    //     "長ねぎの白い部分を加えて1分煮る。",
    //     "水溶き片栗粉を回し入れ、優しく混ぜてとろみをつける。",
    //     "火を止めて砕いた花椒とごま油を加えて混ぜる。",
    //     "器に盛り付け、長ねぎの青い部分を散らして完成。"      ],
    //   "time": "45分",
    //   "cost": "650円",
    //   "createdAt": "${DateTime.now().toIso8601String()}",
    //   "reviwewCount": 0,
    //   "likeCount": 0    }
    // ''';        
    
    // String base64String = '';

    // // モック画像データ
    // try {
    //   ByteData bytes = await rootBundle.load('assets/images/noImage.png');
    //   Uint8List imageBytes = bytes.buffer.asUint8List();
    //   base64String = base64Encode(imageBytes);
    //   // debugPrint("画像をBase64に変換しました: 長さ=${base64String.length}, 最初の50文字=${base64String.substring(0, base64String.length > 50 ? 50 : base64String.length)}");
    // } catch (e) {
    //   debugPrint("アセット画像の読み込みに失敗しました: $e");

    // }

    // final recipe = Recipe.fromJson(json.decode(responseText));

    // recipe.imageBase64 = base64String;


    // return Future.delayed(const Duration(seconds: 2), () => recipe);

    /* 実際にcloud functionを呼び出す場合 */
    try{
      // cloud functionに登録した関数の呼び出し
      final requestBody = json.encode({
        "prompt": prompt
      });
      
      final res = await http.post(
        Uri.parse("$basePath/generateRecipe"),
        headers: {"Content-Type": "application/json"},
        body: requestBody
      );
      
      if (res.statusCode != 200) {
        throw Exception('HTTP Error ${res.statusCode}: ${res.body}');
      }
      
      if (res.body.isEmpty) {
        throw Exception('Empty response body');
      }
        
      try {
        final responseJson = json.decode(res.body);
        
        // レスポンスの構造をデバッグ出力（画像データを除く）
        final debugResponse = Map<String, dynamic>.from(responseJson);
        if (debugResponse.containsKey('imageData')) {
          debugResponse['imageData'] = '[画像データ: ${(debugResponse['imageData'] as String?)?.length ?? 0}文字]';
        }
        debugPrint("Cloud Functionsからのレスポンス: $debugResponse");
        
        // テキストデータ（レシピ情報）の処理
        final Recipe recipe = Recipe.fromJson(responseJson);
        String? imageData;
        if (responseJson.containsKey('imageData')) {
          imageData = responseJson['imageData'] as String?;
          // 画像データを変数に格納するだけ（今後の処理のため）
          debugPrint("画像データを受信しました: ${imageData?.substring(0, 50) ?? 'null'}...");
          recipe.imageBase64 = imageData;
        } 
        
        return recipe;
      }
      catch (e) {
        debugPrint("Recipe parsing error: $e");
        debugPrint("Response body was: ${res.body.substring(0, res.body.length > 300 ? 300 : res.body.length)}");
        throw Exception('Failed to parse recipe: $e');
      }
    } 
    catch (e) {
      debugPrint("Response body was: ${e.toString().substring(0, e.toString().length > 300 ? 300 : e.toString().length)}");
      rethrow;
    }
  }

}
