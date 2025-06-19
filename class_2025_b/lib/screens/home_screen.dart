import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:class_2025_b/widgets/generate.dart';
import 'package:class_2025_b/widgets/search.dart';
import 'package:class_2025_b/widgets/side_menu.dart';
import 'package:class_2025_b/widgets/recipe.dart';
import 'package:class_2025_b/states/home_content_index_provider.dart';


class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = useState<int>(0);

    final drawer = Drawer(
      backgroundColor: Colors.grey[200] ,
      child: SideMenuWidget(),
    );

    final contentIndex = ref.watch(homeContentIndexProvider);
    final recipeId = ref.watch(recipeIdProvider);

    debugPrint("===============recipeId: $recipeId=================");

    final contents = [
      const GenerateWidget(),
      RecipeWidget(recipeId: recipeId),
    ];

    final content = contents[contentIndex.index];

    final screens = [
      content,
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
      ),
      body: screens[index.value],
      drawer: drawer,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index.value,
        onTap: (idx) { 
          index.value = idx;
          if(idx == 0) {
            ref.read(homeContentIndexProvider.notifier).state = Content.generate;
          }
        },
        items: [
          generateItem,
          searchItem,
        ],
      ),
    );
  }

}