// Cloud Functions 第2世代（公式で推奨）
import { onRequest } from 'firebase-functions/v2/https';
import { logger } from 'firebase-functions/v2';
import { GoogleGenAI, Modality } from "@google/genai";
import 'dotenv/config'; // .envファイルを読み込み
import { debug } from 'firebase-functions/logger';

// Gemini API Keyを環境変数から取得
const GEMINI_API_KEY = process.env.GEMINI_API_KEY;

const ai = new GoogleGenAI({apiKey: GEMINI_API_KEY})

export const generateRecipe = onRequest(async (request, response) => {
    
    // Firebase Loggerでログ出力
    logger.info("generateRecipe 関数が呼び出されました", {
      method: request.method,
      url: request.url,
      headers: request.headers,
    });
    
    // CORSヘッダーを設定
  response.set('Access-Control-Allow-Origin', '*');
  response.set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  response.set('Access-Control-Allow-Headers', 'Content-Type');

  // OPTIONSリクエストの場合（プリフライトリクエスト）
  if (request.method === 'OPTIONS') {
    response.status(204).send('');
    return;
  }
  try {
    
    // リクエストからプロンプトを取得
    const { prompt } = request.body;
      if (!prompt) {
      logger.warn("プロンプトが空です");
      response.status(400).json({ error: 'プロンプトが必要です' });
      return;
    }

    // // Recipe形式のモックデータ
    // let responseJson = {
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
    //     "器に盛り付け、長ねぎの青い部分を散らして完成。"
    //   ],
    //   "time": "45分",
    //   "cost": "650円"
    // };

    // responseJson.createdAt = new Date().toISOString();
    // responseJson.reviwewCount = 0;
    // responseJson.likeCount = 0;

    // // レスポンスに画像データを追加（Base64エンコードされた画像）
    // responseJson.imageData = "iVBORw0KGgoAAAANSUhEUgAAAQAAAAEACAIAAADTED8xAAADMElEQVR4nOzVwQnAIBQFQYXff81RUkQCOyDj1YOPnbXWPmeTRef+/3O/OyBjzh3CD95BfqICMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMO0TAAD//2Anhf4QtqobAAAAAElFTkSuQmCC";


    // // モックデータで返す
    // response.status(200).json(responseJson);

    // Gemini APIを呼び出してレシピを生成
    logger.info("Gemini APIを呼び出してレシピを生成中...", { prompt });

    const result = await ai.models.generateContent({
      model: "gemini-2.0-flash-preview-image-generation",
      contents: prompt,
      config: {
        responseModalities: [Modality.TEXT, Modality.IMAGE],
      },
    });

    // logger.info("Gemini API応答:");


    let recipeJson = {};
    let imageBase64 = null;

    // レスポンスを分析
    for (const part of result.candidates[0].content.parts) {

      if (part.text) {

        // logger.info("Gemini API応答テキスト:", part.text);
        // テキスト部分からJSONを抽出
        const responseText = part.text;

        logger.info("=======================================================================================================================================Gemini API応答テキスト:", responseText);

        // より堅牢なJSONクリーニング処理
        let cleanedResponse = responseText;

        // 1. ```json ``` マーカーを除去
        cleanedResponse = cleanedResponse.replace(/```json\s*/g, '');
        cleanedResponse = cleanedResponse.replace(/\s*```/g, '');

        // 2. JSONの開始位置を特定（最初の{を探す）
        const jsonStart = cleanedResponse.indexOf('{');
        const jsonEnd = cleanedResponse.lastIndexOf('}');

        if (jsonStart !== -1 && jsonEnd !== -1 && jsonEnd > jsonStart) {
          cleanedResponse = cleanedResponse.substring(jsonStart, jsonEnd + 1);
        } else {
          logger.error(cleanedResponse.substring(0, 100));
          throw new Error('有効なJSONが見つかりませんでした');
        }

        try{
          recipeJson = JSON.parse(cleanedResponse);
          logger.info("JSONパース成功");
          // レスポンスの構造を確認（画像データを除く）
          const debugResponse = { ...recipeJson };
          logger.info("パースされたレシピデータ:", debugResponse);
        }
        catch (jsonError) {
          logger.error("JSONパースエラー:", jsonError);
          response.status(500).json({ error: 'JSONパースエラー', details: jsonError.message });
          return;
        }
        
      } else if (part.inlineData) {
        // 画像データを取得
        // logger.info("Gemini API応答画像データ:", part.inlineData.data);
        imageBase64 = part.inlineData.data;
      }
    }


    if (imageBase64) {
      recipeJson.imageData = imageBase64;
    }

    // Flutter側のRecipeモデルで必要なフィールドを追加
    recipeJson.createdAt = new Date().toISOString();
    recipeJson.reviwewCount = 0;
    recipeJson.likeCount = 0;

    response.status(200).json(recipeJson);
    
  } catch (error) {
    response.status(500).json({ error: error.message, errorStack: error.stack, errorName: error.name });
  }
});