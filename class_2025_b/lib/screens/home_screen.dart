import 'package:class_2025_b/screens/ingredients_screen.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:class_2025_b/screens/generate_screen.dart';
import 'package:class_2025_b/screens/search_screen.dart';
import 'package:class_2025_b/widgets/side_menu.dart';
import 'package:class_2025_b/screens/recipe_screen.dart';
import 'package:class_2025_b/states/home_state.dart';


class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    final content = ref.watch(currentContentTypeProvider);
    final contentNotifier = ref.read(currentContentTypeProvider.notifier);

    final drawer = Drawer(
      backgroundColor: Colors.grey[200] ,
      child: SideMenuWidget(),
    );

    final screens = [
      GenerateScreen(),
      SearchScreen(),
      RecipeScreen(),
      IngredientsScreen()
    ];

    final generateItem = BottomNavigationBarItem(
      icon: const Icon(Icons.add, color: Colors.grey),
      label: "generate",
    );    
    
    final searchItem = BottomNavigationBarItem(
      icon: const Icon(Icons.search, color: Colors.grey),
      label: "search",
    );
    
    final recipeItem = BottomNavigationBarItem(
      icon: const Icon(Icons.receipt, color: Colors.grey),
      label: "recipe",
    );

    final ingredientsItem = BottomNavigationBarItem(
      icon: const Icon(Icons.kitchen, color: Colors.grey,),
      label: "ingredients",
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Recipe AI"),
      ),
      body: screens[content.index],
      drawer: drawer,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: content.index,
        onTap: (idx) => contentNotifier.state = ContentType.values[idx],
        items: [
          generateItem,
          searchItem,
          recipeItem,
          ingredientsItem
        ],
        selectedItemColor: Colors.grey[500],
        unselectedItemColor: Colors.grey[100],
        selectedLabelStyle: TextStyle(color: Colors.grey[500]), // ラベルのスタイル
        unselectedLabelStyle: TextStyle(color: Colors.grey[100]),
      ),
    );
  }

}