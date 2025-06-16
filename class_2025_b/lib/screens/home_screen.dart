import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:class_2025_b/widgets/generate.dart';
import 'package:class_2025_b/widgets/search.dart';
import 'package:class_2025_b/states/user_state.dart';
import 'package:class_2025_b/widgets/side_menu.dart';


class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = useState<int>(0);

    final user = ref.watch(userProvider);

    final drawer = Drawer(
      backgroundColor: Colors.grey[200] ,
      child: SideMenuWidget(),
    );

    // // 定期実行の処理
    // useEffect(() {
    //   // 3秒ごとに処理を実行するタイマー
    //   final timer = Timer.periodic(const Duration(seconds: 3), (timer) {
    //     debugPrint("定期実行: ${DateTime.now()}");
    //     // ここに実行したい処理を書く
    //     _periodicTask(user);
    //   });

    //   // ウィジェットが破棄される時にタイマーをキャンセル
    //   return () {
    //     timer.cancel();
    //     debugPrint("タイマーをキャンセルしました");
    //   };
    // }, []); // 空の依存配列で初回のみ実行

    final screens = [
      const GenerateWidget(),
      const SearchWidget(),
    ];

    final generateItem = BottomNavigationBarItem(
      icon: const Icon(Icons.add),
      label: "generate",
    );

    final searchItem = BottomNavigationBarItem(
      icon: const Icon(Icons.search),
      label: "search",
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Recipe AI"),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.menu),
        //     onPressed: () {
        //       Scaffold.of(context).openDrawer();
        //     },
        //   ),
        // ],
      ),
      body: screens[index.value],
      drawer: drawer,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index.value,
        onTap: (idx) => index.value = idx,
        items: [
          generateItem,
          searchItem,
        ],
      ),
    );
  }

  // // 定期実行する処理
  // void _periodicTask(user) {
  //   // 例: 現在時刻を表示
  //   debugPrint("定期処理実行中: ${DateTime.now().toString()}");

  //   debugPrint("ユーザーの状態: ${user.toString()}");
    
  //   // 例: 何らかのデータ更新処理
  //   // ref.refresh(someProvider);
    
  //   // 例: 外部APIの呼び出し
  //   // _fetchLatestData();
  // }
}