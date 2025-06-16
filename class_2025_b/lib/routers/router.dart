import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:class_2025_b/screens/login_screen.dart';
import 'package:class_2025_b/screens/register_screen.dart';
import 'package:class_2025_b/screens/home_screen.dart';
import 'package:class_2025_b/screens/recipe_screen.dart';
import 'package:class_2025_b/screens/custom_setting_screen.dart';

final _loginRoute = GoRoute(
  path: "/login",
  builder: (BuildContext context, GoRouterState state) => LoginScreen()
);

final _registerRoute = GoRoute(
  path: "/register",
  builder: (BuildContext context, GoRouterState state) => RegisterScreen()
);

final _homeRoute = GoRoute(
  path: "/",
  builder: (BuildContext context, GoRouterState state) => HomeScreen()
);

final _recipeRoute = GoRoute(
  path: "/recipe/:recipeId",
  builder: (BuildContext context, GoRouterState state) {
    final recipeId = state.pathParameters['recipeId'];
    return RecipeScreen(recipeId: recipeId);
  }
);

final _customSettingRoute = GoRoute(
  path: "/customSettings",
  builder: (BuildContext context, GoRouterState state) => CustomSettingScreen()
);


final GoRouter _router = GoRouter(

  initialLocation: "/",

  routes: <GoRoute>[
    _loginRoute,
    _registerRoute,
    _homeRoute,
    _recipeRoute,
    _customSettingRoute
  ]

);

class AppRouter{
  static GoRouter router = _router;

  static void goToLogin(BuildContext context) {
    context.go("/login");
  }

  static void goToHome(BuildContext context) {
    context.go("/");
  }

  static void goToRecipe(BuildContext context, String recipeId) {
    context.go("/recipe/$recipeId");
  }

  static void goToCustomSetting(BuildContext context) {
    context.go("/customSettings");
  }

  static void goToRegister(BuildContext context) {
    context.go("/register");
  }

}