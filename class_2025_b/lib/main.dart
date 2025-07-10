
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
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;


void main() async {

  if(kIsWeb){
    hostingHost   = hostForLocal;
    functionsHost = hostForLocal;
    firestoreHost = hostForLocal;
    storageHost   = hostForLocal;
    authHost      = hostForLocal;
  }
  else if(Platform.isAndroid) {
    // Androidエミュレータの場合
    hostingHost   = hostForAndroidEmulator;
    functionsHost = hostForAndroidEmulator;
    firestoreHost = hostForAndroidEmulator;
    storageHost   = hostForAndroidEmulator;
    authHost      = hostForAndroidEmulator;
  }
  else {
    // その他のプラットフォーム（iOSやデスクトップなど）
    hostingHost   = hostForLocal;
    functionsHost = hostForLocal;
    firestoreHost = hostForLocal;
    storageHost   = hostForLocal;
    authHost      = hostForLocal;
  }

  // Firebaseの初期化　おまじない
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  try {
    // エミュレータの設定
    FirebaseFirestore.instance.useFirestoreEmulator(firestoreHost, 8080);
    FirebaseFunctions.instance.useFunctionsEmulator(functionsHost, 5001);
    FirebaseStorage.instance.useStorageEmulator(storageHost, 9199);
    await FirebaseAuth.instance.useAuthEmulator(authHost, 9099); 
   } 
   catch (e) {
    debugPrint(e.toString());
   }   

  final scope = ProviderScope(child: RecipeAI());
  runApp(scope);
}