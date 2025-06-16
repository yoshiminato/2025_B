import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:class_2025_b/routers/router.dart';
import 'package:class_2025_b/widgets/search.dart';
import 'package:class_2025_b/states/user_state.dart';

class SideMenuWidget extends ConsumerWidget {
  const SideMenuWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final header = DrawerHeader(child: Text("header"));

    final signedIn = ref.watch(signedInProvider);

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
      onTap: () => signedIn ?
        () {
          // ログアウト処理を実行
          AppRouter.goToHome(context);
        } :
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("ログインしていません"))
        )
    );

    final customizeTile = ListTile(
      leading: const Icon(Icons.settings),
      title: const Text("カスタマイズ"),
      onTap: () => AppRouter.goToCustomSetting(context),
    );

    final column = Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        header,
        loginTile,
        logoutTile,
        customizeTile
      ],
    );
    return column;
  }
}