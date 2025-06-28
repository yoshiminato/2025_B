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

  // final ip = "localhost";
  final ip = "10.0.2.2";


  // Firebaseの初期化　おまじない
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  try {
    // エミュレータの設定
    FirebaseFirestore.instance.useFirestoreEmulator(ip, 8080);
    FirebaseFunctions.instance.useFunctionsEmulator(ip, 5001);
    FirebaseStorage.instance.useStorageEmulator(ip, 9199);
    await FirebaseAuth.instance.useAuthEmulator(ip, 9099); 
   } 
   catch (e) {
    debugPrint(e.toString());
   }   

  final scope = ProviderScope(child: RecipeAI());
  runApp(scope);
}