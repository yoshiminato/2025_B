import 'package:flutter/material.dart';
import 'package:class_2025_b/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


void main() async {

  // Firebaseの初期化　おまじない
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final scope = ProviderScope(child: RecipeAI());
  runApp(scope);
}
