import 'package:class_2025_b/screens/ingredients_screen.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:class_2025_b/screens/generate_screen.dart';
import 'package:class_2025_b/screens/search_screen.dart';
import 'package:class_2025_b/widgets/side_menu.dart';
import 'package:class_2025_b/screens/recipe_screen.dart';
import 'package:class_2025_b/states/home_state.dart';

/*
2025/07/09 安田　デザイン調整
  ・背景色変更
  ・リップルエフェクト調整
  ・アイコン、文字色の調整
  　ーItemからColorの指定を削除
  ・選択/非選択時のアイコンサイズを調整
*/

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.watch(homeContentTypeProvider);
    final contentNotifier = ref.read(homeContentTypeProvider.notifier);

    final drawer = Drawer(
      backgroundColor: const Color.fromARGB(255, 248, 240, 238),
      child: SideMenuWidget(),
    );

    final screens = [
      GenerateScreen(),
      SearchScreen(),
      RecipeScreen(),
      IngredientsScreen(),
    ];

    // BottomNavigationBarのアイテムを定義(アイコンとラベル)
    final generateItem = BottomNavigationBarItem(
      icon: const Icon(Icons.add),
      label: "generate",
    );

    final searchItem = BottomNavigationBarItem(
      icon: const Icon(Icons.search),
      label: "search",
    );

    final recipeItem = BottomNavigationBarItem(
      icon: const Icon(Icons.receipt),
      label: "recipe",
    );

    final ingredientsItem = BottomNavigationBarItem(
      icon: const Icon(Icons.kitchen),
      label: "ingredients",
    );
    return Scaffold(
      appBar: AppBar(title: const Text("Recipe AI")),
      body: screens[content.index],
      drawer: drawer,
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: const Color.fromARGB(48, 255, 187, 119),
          highlightColor: const Color.fromARGB(96, 246, 162, 129),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: content.index,
          onTap: (idx) => contentNotifier.state = ContentType.values[idx],
          items: [generateItem, searchItem, recipeItem, ingredientsItem],
          // ButtonNavigationBarのスタイル
          selectedIconTheme: const IconThemeData(size: 33),
          unselectedIconTheme: const IconThemeData(size: 22),
          selectedItemColor: Colors.orange,
          unselectedItemColor: const Color.fromARGB(255, 234, 180, 126),
          selectedLabelStyle: TextStyle(
            color: const Color.fromARGB(255, 233, 140, 0),
          ), // ラベルのスタイル
          unselectedLabelStyle: TextStyle(
            color: const Color.fromARGB(255, 233, 187, 119),
          ),
        ),
      ),
    );
  }
}
