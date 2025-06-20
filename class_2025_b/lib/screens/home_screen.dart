import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:class_2025_b/widgets/generate_widget.dart';
import 'package:class_2025_b/widgets/search_widget.dart';
import 'package:class_2025_b/widgets/side_menu.dart';
import 'package:class_2025_b/widgets/recipe_widget.dart';
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
      const GenerateWidget(),
      const SearchWidget(),
      const RecipeWidget(),
    ];

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
          recipeItem
        ],
      ),
    );
  }

}