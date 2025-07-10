import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

void debugLog(String message) {
  if (kDebugMode) {
    print('[DEBUG] $message'); // printはブラウザコンソールに出力される
    debugPrint('[DEBUG] $message'); // debugPrintも併用
  }
}

String replaceHostInUrl(String url, String newHost) {
  // http(s)://[IP or host]:[port]/
  final reg = RegExp(r'^(https?://)([^:/]+)(:\\d+)?');
  return url.replaceFirstMapped(reg, (m) {
    final scheme = m.group(1) ?? '';
    final port = m.group(3) ?? '';
    return '$scheme$newHost$port';
  });
}

// // Web/Android用: 10.0.2.2→hostingIP 変換
// String fixEmulatorUrlForWeb(String url) {
//   if (kIsWeb) {
//     // Webの場合はhostingIPに変換
//     return replaceHostInUrl(url, hostingIP);
//   } else {
//     try {
//       if (Platform.isAndroid) {
//         // Android実機の場合もhostingIPに変換
//         return replaceHostInUrl(url, hostingIPForAndroidEmulator);
//       }
//     } catch (_) {
//       // WebではPlatformは使えないので例外を握りつぶす
//     }
//   }
//   return url;
// }

// エミュレータと同じ端末で実行する場合のホスティングIP
const hostForLocal = "localhost"; // ローカルホスト

// Androidエミュレータ用のホスティングIP(Androidエミュレータから見たfirebaseEmulatorが起動している端末ののIP)
const hostForAndroidEmulator = "10.0.2.2";

// 以下のIPはローカルでのテスト用
// const hostingIP = "localhost";
// const functionsIP = hostingIP;
// const firestoreIP = hostingIP;
// const storageIP   = hostingIP; 
// const authIP      = hostingIP;

// 以下のIPはローカルトンネルを使う場合のテスト用
// url発行ごとに書き換える必要あり
// const hostingHost   = "hosting.loca.lt";
// const functionsHost = "functions.loca.lt";
// const firestoreHost = "firestore.loca.lt";
// const storageHost   = "storage.loca.lt";
// const authHost      = "auth.loca.lt";

// 以下のIPはCloudflare Tunnelを使う場合のテスト用
// url発行ごとに書き換える必要あり
// const hostingHost   = "posts-advantage-collective-cookies.trycloudflare.com";
// const functionsHost = "tube-ev-payments-scenes.trycloudflare.com";
// const firestoreHost = "throws-toll-minimize-nasa.trycloudflare.com";
// const storageHost   = "entirely-food-ks-nursing.trycloudflare.com";
// const authHost      = "titanium-expects-locked-webmaster.trycloudflare.com";

// Androidエミュレータで実行する場合
const hostingHost   = hostForAndroidEmulator;
const functionsHost = hostForAndroidEmulator;
const firestoreHost = hostForAndroidEmulator;
const storageHost   = hostForAndroidEmulator;
const authHost      = hostForAndroidEmulator;

// // エミュレータと同じ端末で実行する場合
// const hostingHost   = hostForLocal;
// const functionsHost = hostForLocal;
// const firestoreHost = hostForLocal;
// const storageHost   = hostForLocal;
// const authHost      = hostForLocal;

// 画面上にログを表示するためのグローバル変数
List<String> debugMessages = [];

// 画面上にログを表示する関数
void showDebugMessage(String message) {
  if (kDebugMode) {
    debugMessages.add('[${DateTime.now().toString().substring(11, 19)}] $message');
    if (debugMessages.length > 10) {
      debugMessages.removeAt(0); // 最新10件のみ保持
    }
    print('[SHOW] $message');
    debugPrint('[SHOW] $message');
  }
}