import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:class_2025_b/screens/login_screen.dart';
import 'package:class_2025_b/screens/register_screen.dart';
import 'package:class_2025_b/screens/home_screen.dart';
// import 'package:class_2025_b/screens/recipe_screen.dart';
import 'package:class_2025_b/screens/custom_setting_screen.dart';
// import 'package:class_2025_b/screens/comment_test_screen.dart';
import 'package:class_2025_b/screens/camera_capture_screen.dart';

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

final _customSettingRoute = GoRoute(
  path: "/customSettings",
  builder: (BuildContext context, GoRouterState state) => CustomSettingScreen()
);


final _cameraCaptureRoute = GoRoute(
  path: "/cameraCapture",
  builder: (BuildContext context, GoRouterState state) => CameraCaptureScreen()
);


final GoRouter _router = GoRouter(

  initialLocation: "/login",

  routes: <GoRoute>[
    _loginRoute,
    _registerRoute,
    _homeRoute,
    _customSettingRoute,
    _cameraCaptureRoute,
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

  static void goToCustomSetting(BuildContext context) {
    context.go("/customSettings");
  }

  static void goToRegister(BuildContext context) {
    context.go("/register");
  }


  static void goToCameraCapture(BuildContext context) {
    context.go("/cameraCapture");
  }
}