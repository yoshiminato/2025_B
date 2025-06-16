import 'package:class_2025_b/routers/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class CustomSettingScreen extends ConsumerWidget {
  const CustomSettingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("カスタマイズ設定"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("カスタマイズ設定画面"),
            ElevatedButton(
              onPressed: () => AppRouter.goToHome(context),
              child: Text("ホームに戻る")
            ),
          ],
        ),
      ),
    );
  }
}