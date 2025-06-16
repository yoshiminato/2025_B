import 'package:flutter/material.dart';
import 'package:class_2025_b/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


void main() async {
  final scope = ProviderScope(child: RecipeAI());
  runApp(scope);
}
