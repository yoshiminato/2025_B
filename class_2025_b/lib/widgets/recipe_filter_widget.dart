import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RecipeFilterWidget extends ConsumerWidget {
  const RecipeFilterWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    // ヘッダーの高さ(文字列「イメージ----」,「予算----」などの高さ)
    final headerHeight = 50.0;

    // キーワード入力部分
    final textField = TextField(
      decoration: InputDecoration(
        labelText: 'レシピ名で検索',
        border: OutlineInputBorder(),
      ),
      onChanged: (value) {
        // 検索処理をここに追加
      },
    );

    // キーワード入力部分のコンテナ
    final textFieldContainer = Container(
      padding: const EdgeInsets.all(16.0),
      child: textField
    );

    // イメージのヘッダー部分
    final imageHeaderText = const Text(
      'イメージ----------------------------------------',
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
    );

    // イメージのヘッダー部分のコンテナ
    final imageHeaderContainer = Container(
      height: headerHeight,
      child: imageHeaderText
    ); 

    // ボタンは3列
    const col = 3;

    // ボタンは2行
    const row = 2;

    // 選択肢のボタン群
    final imageButtons = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (int i = 0; i < row; i++)
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int j = 0; j < col; j++)
                ElevatedButton(
                  onPressed: () {
                    // 画像選択処理をここに追加
                  },
                  child: Text('選択肢'),
              ),
            ],
          ),
      ],
    );

    // イメージのコンテナ
    final imageContainer = Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          imageHeaderContainer,
          imageButtons,
        ],
      ),
    ); 

    // コストのヘッダー部分
    final costHeaderText = const Text(
      'コスト----------------------------------------',
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
    );

    // コストのヘッダー部分のコンテナ
    final costHeaderContainer = Container(
      height: headerHeight,
      child: costHeaderText
    );

    // 予算のヘッダー部分
    final budgetHeaderText = const Text(
      '予算',
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
    );

    // 予算のヘッダー部分のコンテナ
    final budgetHeaderContainer = Container(
      height: headerHeight,
      child: budgetHeaderText
    );

    // 予算のスライダー
    final budgetSlider = Slider(
      value: 0.0,
      min: 0.0,
      max: 10000.0,
      divisions: 100,
      label: '予算',
      onChanged: (value) {
        // スライダーの値変更処理をここに追加
      },
    );

    // 予算のスライダーのコンテナ
    final budgetSliderContainer = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: budgetSlider,
    );

    // 予算のコンテナ
    final budgetContainer = Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          budgetHeaderContainer,
          Expanded(child: budgetSliderContainer,)
        ],
      ),
    );

    // 調理時間のヘッダー部分
    final timeHeaderText = const Text(
      '調理時間',
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
    );

    // 調理時間のヘッダー部分のコンテナ
    final timeHeaderContainer = Container(
      height: headerHeight,
      child: timeHeaderText
    );

    // 調理時間のスライダー
    final timeSlider = Slider(
      value: 0.0,
      min: 0.0,
      max: 120.0,
      divisions: 24,
      label: '調理時間',
      onChanged: (value) {
        // スライダーの値変更処理をここに追加
      },
    );

    // 調理時間のスライダーのコンテナ
    final timeSliderContainer = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: timeSlider,
    );

    // 調理時間のコンテナ
    final timeContainer = Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          timeHeaderContainer,
          Expanded(child: timeSliderContainer,),
        ],
      ),
    );

    // フィルター全体のコンテナ
    final costContainer = Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          costHeaderContainer,
          budgetContainer,
          timeContainer,
        ],
      ),
    );

    // フィルター全体のコンテナ
    final filterContainer = Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          textFieldContainer,
          imageContainer,
          costContainer
        ],
      ),
    );

    return filterContainer;
  }
}