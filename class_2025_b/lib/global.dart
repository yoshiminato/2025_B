import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';

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

// ポート番号を置換する関数
String replacePortInUrl(String url, int newPort) {
  // http(s)://host(:oldPort)?/path → http(s)://host:newPort/path
  final reg = RegExp(r'^(https?://[^/:]+)(:\d+)?(\/.*)?');
  return url.replaceFirstMapped(reg, (m) {
    final schemeHost = m.group(1) ?? '';
    final path = m.group(3) ?? '';
    return '$schemeHost:$newPort$path';
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

// ローカルエミュレータのポート
const int localFirestorePort = 8080;
const int localFunctionsPort = 5001;
const int localStoragePort = 9199;
const int localAuthPort = 9099;

class CloudFlare{
  static const String hostingHost   = "host.2025classb.com";
  static const String functionsHost = "functions.2025classb.com";
  static const String firestoreHost = "firestore.2025classb.com";
  static const String storageHost   = "storage.2025classb.com";
  static const String authHost      = "auth.2025classb.com";
  static const int port = 443;
}


// グローバル変数（初期化）
String hostingHost   = CloudFlare.hostingHost;
String functionsHost = CloudFlare.functionsHost;
String firestoreHost = CloudFlare.firestoreHost;
String storageHost   = CloudFlare.storageHost;
String authHost      = CloudFlare.authHost;
int functionsPort    = CloudFlare.port;
int firestorePort    = CloudFlare.port;
int storagePort      = CloudFlare.port;
int authPort         = CloudFlare.port;

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