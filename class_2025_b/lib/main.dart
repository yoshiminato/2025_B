import 'package:class_2025_b/global.dart';
import 'package:flutter/material.dart';
import 'package:class_2025_b/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:cloud_functions/cloud_functions.dart";
import 'package:firebase_storage/firebase_storage.dart';


void main() async {

  // Cloudflare Tunnelを使う場合の設定(使用しない場合はコメントアウト)
  hostingHost   = CloudFlare.hostingHost;
  functionsHost = CloudFlare.functionsHost;
  firestoreHost = CloudFlare.firestoreHost;
  storageHost   = CloudFlare.storageHost;
  authHost      = CloudFlare.authHost;
  functionsPort = CloudFlare.port;
  firestorePort = CloudFlare.port;
  storagePort   = CloudFlare.port;
  authPort      = CloudFlare.port;
  
  print("=== After Init Check ===");
  print("firestorePort: $firestorePort");

  // // プラットフォーム別のデフォルト設定（ローカル用）
  // if(kIsWeb){
  //   hostingHost   = hostForLocal; 
  //   functionsHost = hostForLocal;
  //   firestoreHost = hostForLocal;
  //   storageHost   = hostForLocal;
  //   authHost      = hostForLocal;
  // }
  // else if(Platform.isAndroid) {
  //   // Androidエミュレータの場合
  //   hostingHost   = hostForAndroidEmulator;
  //   functionsHost = hostForAndroidEmulator;
  //   firestoreHost = hostForAndroidEmulator;
  //   storageHost   = hostForAndroidEmulator;
  //   authHost      = hostForAndroidEmulator;
  // }
  // else {
  //   // その他のプラットフォーム（iOSやデスクトップなど）
  //   hostingHost   = hostForLocal;
  //   functionsHost = hostForLocal;
  //   firestoreHost = hostForLocal;
  //   storageHost   = hostForLocal;
  //   authHost      = hostForLocal;
  // }
  // functionsPort = localFunctionsPort;
  // firestorePort = localFirestorePort;
  // storagePort   = localStoragePort;
  // authPort      = localAuthPort;

  // Firebaseの初期化　おまじない
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // エミュレータの接続
  try {
    // Cloudflare Tunnelを使用する場合（HTTPSスキームを明示的に指定）
    
    // Firebase SDKのデバッグログを有効にする
    // FirebaseFirestore.instance.settings = const FirestoreSettings(
    //   persistenceEnabled: false,
    // );

    print("=== Firebaseエミュレータに接続中 ===");
    print("functions: $functionsHost:$functionsPort");
    print("firestore: $firestoreHost:$firestorePort");
    print("storage: $storageHost:$storagePort");
    print("auth: $authHost:$authPort");
    
    
    FirebaseFirestore.instance.useFirestoreEmulator(firestoreHost, firestorePort);
    FirebaseFunctions.instance.useFunctionsEmulator(functionsHost, functionsPort);
    FirebaseStorage.instance.useStorageEmulator(storageHost, storagePort);
    await FirebaseAuth.instance.useAuthEmulator(authHost, authPort);

    // // ローカルエミュレータを使用する場合
    // FirebaseFirestore.instance.useFirestoreEmulator(firestoreHost, localFirestorePort);
    // FirebaseFunctions.instance.useFunctionsEmulator(functionsHost, localFunctionsPort);  
    // FirebaseStorage.instance.useStorageEmulator(storageHost, localStoragePort);
    // await FirebaseAuth.instance.useAuthEmulator(authHost, localAuthPort);

    print("Firebaseのエミュレータに接続しました。");
    print("Firestore Host: $firestoreHost");
    print("Functions Host: $functionsHost");
    print("Storage Host: $storageHost");
    print("Auth Host: $authHost");
    
    // 接続テストを実行
    await testFirestoreConnection();
   } 
   catch (e) {
    print("Firebase接続エラー: ${e.toString()}");
   }   

  final scope = ProviderScope(child: RecipeAI());
  runApp(scope);
}

// Firestore接続テスト関数
Future<void> testFirestoreConnection() async {
  try {
    print("=== Firestore接続テスト開始 ===");
    
    // 簡単なコレクション参照を作成
    final testRef = FirebaseFirestore.instance.collection('test');
    
    // タイムアウト付きでドキュメント取得を試行
    final future = testRef.limit(1).get();
    final result = await future.timeout(
      const Duration(seconds: 15),
      onTimeout: () {
        throw Exception('Firestore接続がタイムアウトしました');
      },
    );
    
    print("Firestore接続成功: ${result.docs.length} documents");
  } catch (e) {
    print("Firestore接続テスト失敗: ${e.toString()}");
  }
}