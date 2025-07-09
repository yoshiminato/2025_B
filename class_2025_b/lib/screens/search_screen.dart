import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:class_2025_b/widgets/search_result_widget.dart';
import 'package:class_2025_b/widgets/search_default_widget.dart';
import 'package:class_2025_b/states/search_state.dart';


class SearchScreen extends HookConsumerWidget {
  
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    // テキストのコントローラ
    final searchTextController = useTextEditingController(text: ref.read(searchTextProvider));

    // 検索結果の有無で画面更新
    final hasResult = ref.watch(hasSearchResultProvider);

    // 検索ボックスのテキストフィールド
    final searchTextField = TextField(
      controller: searchTextController,
      decoration: InputDecoration(
        hintText: '材料名をスペース区切りで入力',
        prefixIcon: Padding(
          padding: EdgeInsets.only(left: 8, right: 4, top: 2, bottom: 2),
          child: Icon(Icons.search, size: 16),
        ),
        border: OutlineInputBorder(
        ),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      ),

      
      /* テキストの変更をプロバイダに伝達 */
      onChanged: (value) {
        // プロバイダのNotifierを取得
        final searchTextNotifier = ref.read(searchTextProvider.notifier);
        // Notifierを使ってプロバイダの値を更新
        searchTextNotifier.state = value;
      },

      /* 検索文字列が提出されたら検索処理 */
      onSubmitted: (value) async {
        try{
          // 検索結果プロバイダのNotifierを取得
          final searchResultNotifier = ref.read(searchResultNotifierProvider.notifier);
          // 検索結果を有で更新
          ref.read(hasSearchResultProvider.notifier).state = true;
          // 検索処理
          await searchResultNotifier.updateSearchResult();
        } 
        catch (e) {
          // エラーが発生した場合はスナックバーで通知
          if(!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("検索中にエラーが発生しました: $e")),
          );
        }
      },
    );

    // 検索ボックスのテキストフィールドをコンテナに入れる
    final searchTextFieldContainer = SizedBox(
      height: 40,
      child: searchTextField
    );

    // ソートアイコンボタン
    final sortIcon = IconButton(
      icon: const Icon(Icons.sort),
      tooltip: 'ソート・フィルター',
      onPressed: () {
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (context) {
            return SafeArea(
              child: SortSelecterWidget()
            );
          },
        );
      },
    );

    // 検索ボックスの入力パネル
    final inputPanel = Container(
      padding: const EdgeInsets.all(16.0),
      width: double.infinity,
      height: 80,
      child: Row(
        children: [
          Expanded(child: searchTextFieldContainer),
          hasResult ?
          sortIcon : const SizedBox.shrink(), // 検索結果がない場合はフィルターアイコンを表示しない
        ],
      ),
    );

    // 検索ボックスとコンテンツを並べて返す
    return Column(
      children: [
        inputPanel,
        // 検索結果がある場合はSearchResultWidgetを表示
        Expanded(
          child: hasResult
          ?
          SearchResultWidget()
          :
          SearchDefaultWidget(),
        ),
      ],
    );
  }
}
