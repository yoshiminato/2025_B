import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:class_2025_b/states/generate_state.dart';
import 'package:class_2025_b/states/recipe_id_state.dart';
import 'package:class_2025_b/states/home_state.dart';
import 'package:class_2025_b/states/search_state.dart';

// アプリ名
const appName = "ゴハンナニ？";


String getHttpUrl(String host, int port, String path) {
  // http://host:port/path
  // パスが既に/で始まっている場合は重複を避ける
  final cleanPath = path.startsWith('/') ? path : '/$path';
  return 'http://$host:$port$cleanPath';
}

String getHttpsUrl(String host, int port, String path) {
  // https://host:port/path
  // パスが既に/で始まっている場合は重複を避ける
  final cleanPath = path.startsWith('/') ? path : '/$path';
  return 'https://$host:$port$cleanPath';
}

// URLからパス部分のみを抽出する関数
String extractPathFromUrl(String url) {
  final reg = RegExp(r'^https?:\/\/[^\/]+(.*)');
  final match = reg.firstMatch(url);
  return match?.group(1) ?? '/';
}

void initState(WidgetRef ref) {
  // 初期化処理
  // 生成画面に戻す
  final homeContentTypeNotifier = ref.read(homeContentTypeProvider.notifier);
  homeContentTypeNotifier.state = ContentType.generate;
  // レシピIDをクリア
  final recipeIdNotifier = ref.read(recipeIdProvider.notifier);
  recipeIdNotifier.state = null;
  // 生成状態を初期化
  final generateStateNotifier = ref.read(generateStateNotifierProvider.notifier);
  generateStateNotifier.updateState(GenerateState.initial);
  // 検索関係の状態を初期化
  ref.read(hasSearchResultProvider.notifier).state = false;
  ref.read(searchTextProvider.notifier).state = '';
  ref.read(searchTriggerProvider.notifier).state++;
}

// エミュレータと同じ端末で実行する場合のホスティングIP
const hostForLocal = "localhost"; // ローカルホスト

// Androidエミュレータ用のホスティングIP(Androidエミュレータから見たfirebaseEmulatorが起動している端末ののIP)
const hostForAndroidEmulator = "10.0.2.2";


// Android実機用のホスティングIP(実機から見たfirebaseEmulatorが起動している端末のIP)
// const hostForAndroidDevice = "169.254.83.107";
// const hostForAndroidDevice = "192.168.11.13";
// const hostForAndroidDevice = "10.170.6.228";
const hostForAndroidDevice = "192.168.10.110";

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

String Function(String host, int port, String path) getUrl = (host, port, path) => getHttpsUrl(host, port, path);



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

// URLに?alt=mediaパラメータを追加する関数
String ensureAltMediaParameter(String url) {
  // 既に?alt=mediaが含まれている場合はそのまま返す
  if (url.contains('?alt=media')) {
    return url;
  }
  
  // URLが空の場合は?alt=mediaのみを返す
  if (url.isEmpty) {
    return '?alt=media';
  }
  
  // 既にクエリパラメータがある場合は&alt=mediaを追加
  if (url.contains('?')) {
    return '$url&alt=media';
  }
  
  // クエリパラメータがない場合は?alt=mediaを追加
  return '$url?alt=media';
}