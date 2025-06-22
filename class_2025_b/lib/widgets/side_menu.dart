import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:class_2025_b/routers/router.dart';
import 'package:class_2025_b/states/user_state.dart';
import 'package:class_2025_b/services/auth_service.dart';

class SideMenuWidget extends ConsumerWidget {
  const SideMenuWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final header = DrawerHeader(child: Text("header"));

    final signedIn = ref.watch(signedInProvider);

    final authService = AuthService();


    final loginTile = ListTile(
      leading: const Icon(Icons.login),
      title: const Text("ログイン"),
      onTap: signedIn ?
        () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("すでにログインしています"))
              ) :
        () => AppRouter.goToLogin(context)
    );

    final logoutTile = ListTile(
      leading: const Icon(Icons.logout),
      title: const Text("ログアウト"),
      onTap: signedIn ?
        () async {
          // ログアウト処理を実行
          try{
            debugPrint("ログアウト処理を開始");
            await authService.signOut();
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("ログアウトしました"))
            );
          }catch(e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("ログアウトに失敗しました: $e"))
            );
          }
        } :
        () => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("ログインしていません"))
              ),  
    );

    final customizeTile = ListTile(
      leading: const Icon(Icons.settings),
      title: const Text("カスタマイズ"),
      onTap: () => AppRouter.goToCustomSetting(context),
    );

    final commentTestTile = ListTile(
      leading: const Icon(Icons.comment),
      title: const Text("コメントテスト"),
      onTap: () => AppRouter.goToCommentTest(context),
    );

    final column = Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        header,
        loginTile,
        logoutTile,
        customizeTile,
        commentTestTile,
      ],
    );
    return column;
  }
}