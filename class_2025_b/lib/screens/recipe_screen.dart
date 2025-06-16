import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:class_2025_b/routers/router.dart';

class RecipeScreen extends StatelessWidget {
  final String? recipeId;
  
  const RecipeScreen({super.key, this.recipeId});

  @override
  Widget build(BuildContext context) {
    final container = Container(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "ﾚｼﾋﾟ画面",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: () => AppRouter.goToHome(context), 
                  child: const Text("ﾎｰﾑに戻る")
                )
              ],
            )
          ),
        ); 
     return Scaffold(
      appBar: AppBar(
                title: const Text("Recipe Details"),
              ),
        body: container
      );
  }
    
}