// Cloud Functions 第2世代（公式で推奨）
const functions = require('firebase-functions/v2');
const { GoogleGenerativeAI } = require('@google/generative-ai');
require('dotenv').config(); // .envファイルを読み込み

// Gemini API Keyを環境変数から取得
const GEMINI_API_KEY = process.env.GEMINI_API_KEY || (functions.config().gemini && functions.config().gemini.api_key);
const genAI = new GoogleGenerativeAI(GEMINI_API_KEY);

// // 外部からアクセスできる関数を定義
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   // Firebaseのログに出力
//   functions.logger.info("Hello logs!", {structuredData: true});
  
// //   // CORSヘッダーを設定（Flutter アプリからのアクセスを許可）
// //   response.set('Access-Control-Allow-Origin', '*');
// //   response.set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
// //   response.set('Access-Control-Allow-Headers', 'Content-Type');
  
// //   // OPTIONSリクエストの場合（プリフライトリクエスト）
// //   if (request.method === 'OPTIONS') {
// //     response.status(204).send('');
// //     return;
// //   }
  
//   // JSONレスポンスを送信
//   response.status(200).json({
//     data: "Hello from Firebase!",
//     // timestamp: new Date().toISOString(),
//     // method: request.method
//   });
// });

exports.generateRecipe = functions.https.onRequest(async (request, response) => {
    
    // Firebase Loggerでログ出力
    functions.logger.info("generateRecipe 関数が呼び出されました", {
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
      functions.logger.warn("プロンプトが空です");
      response.status(400).json({ error: 'プロンプトが必要です' });
      return;
    }    

    // // Recipe形式のモックデータ
    const mockRecipe = {
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
    };

    // モックデータを返す
    response.status(200).json(mockRecipe);

    // const model = genAI.getGenerativeModel({ model: 'gemini-1.5-flash' });
    // const result = await model.generateContent(prompt);
    // const responseText = result.response.text();

    // // Geminiからのレスポンスを処理（Markdownコードブロックを除去）
    // let cleanedResponse = responseText;
    
    // // ```json と ``` を除去
    // if (cleanedResponse.includes('```json')) {
    //   cleanedResponse = cleanedResponse.replace(/```json\s*/g, '');
    //   cleanedResponse = cleanedResponse.replace(/\s*```/g, '');
    // }
    
    // // 余分な空白や改行を整理
    // cleanedResponse = cleanedResponse.trim();
    
    // functions.logger.info("クリーンアップ後のレスポンス:", {
    //   cleanedLength: cleanedResponse.length,
    //   cleanedStart: cleanedResponse.substring(0, 200) + '...'
    // });

    // // JSONパースして有効性を確認
    // try {
    //   const parsedJson = JSON.parse(cleanedResponse);
    //   functions.logger.info("JSONパース成功:", parsedJson.title || 'タイトル未取得');
      
    //   // Recipe形式のJSONを直接返す
    //   response.status(200).json(parsedJson);
    // } catch (parseError) {
    //   functions.logger.error("JSONパースエラー:", parseError);
    //   functions.logger.error("パース対象文字列:", cleanedResponse);
      

      
    //   response.status(200).json(mockRecipe);
    // }
    // return;

  } catch (error) {
    functions.logger.error('Gemini API エラーの詳細:', {
      message: error.message,
      stack: error.stack,
      name: error.name,
      code: error.code || 'unknown'
    });
    console.error('Gemini API エラー:', error);
    
    // エラーの種類に応じて詳細なメッセージを返す
    let errorMessage = 'Gemini APIの呼び出しでエラーが発生しました';
    if (error.message.includes('API_KEY')) {
      errorMessage = 'Gemini API Key が無効です';
    } else if (error.message.includes('quota')) {
      errorMessage = 'API利用制限に達しました';
    } else if (error.message.includes('network')) {
      errorMessage = 'ネットワークエラーが発生しました';
    }
    
    response.status(500).json({
      error: errorMessage,
      details: error.message
    });
  }
});
