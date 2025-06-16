import 'package:flutter/material.dart';
import 'routers/router.dart';

class RecipeAI extends StatelessWidget {
  const RecipeAI({super.key});

  @override
  Widget build(BuildContext context) {
    final router = AppRouter.router;
    return MaterialApp.router(
      routeInformationProvider: router.routeInformationProvider,
      routeInformationParser: router.routeInformationParser,
      routerDelegate: router.routerDelegate,
    );
  }
}