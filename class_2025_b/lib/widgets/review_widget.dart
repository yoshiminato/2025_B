import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:class_2025_b/states/review_state.dart';
import 'package:class_2025_b/models/review_model.dart';
import 'package:class_2025_b/states/user_state.dart';
import 'package:class_2025_b/states/search_state.dart';

// レビューの入力・投稿部分のウィジェット
class ReviewFormWidget extends HookConsumerWidget {

  final Review review;

  const ReviewFormWidget({super.key, required this.review});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    // レビューの状態をデータベースでの登録値で初期化
    final tasteRating = useState(review.tasteRating);
    final easeRating  = useState(review.easeRating);
    final costRating  = useState(review.cospRating);
    final uniquenessRating = useState(review.uniquenessRating);

    final user = ref.watch(userProvider);

    // レビューのを投稿可能かどうかをチェック(全項目入力＆ログイン)
    final bool isValid = tasteRating.value > 0 && easeRating.value > 0 && costRating.value > 0 && uniquenessRating.value > 0 && user != null;

    return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ReviewRatingRow(label: '味', notifier: tasteRating),
      SizedBox(height: 16),
      ReviewRatingRow(label: '作りやすさ', notifier: easeRating),
      SizedBox(height: 16),
      ReviewRatingRow(label: 'コスパ', notifier: costRating),
      SizedBox(height: 16),
      ReviewRatingRow(label: '奇抜さ', notifier: uniquenessRating),
      SizedBox(height: 16),
      isValid ? SizedBox.shrink() :
      Center(
        child: Text(
          'レビューを投稿するには、ログインした状態すべての評価を設定してください',
          style: TextStyle(color: Colors.red),
        ),
      ),
      SizedBox(height: 16),
      // レビュー投稿ボタン
      Center(
        child: ElevatedButton(
          onPressed: isValid ? () async {
            await addReview(
              tasteRating.value,
              easeRating.value,
              costRating.value,
              uniquenessRating.value,
              ref
            );
            if(!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("レビューを投稿しました")));
            ref.read(searchTriggerProvider.notifier).state++;
          } : null,
          child: const Text('レビューを投稿する'),
        )
      )
    ],
  );
  }
}

// レビューウィジェット全体を表示するウィジェット
class ReviewWidget extends HookConsumerWidget {

  const ReviewWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final header = SizedBox(
      child: Text(
        'レビュー',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    final asyncReview = ref.watch(reviewProvider);

    // レビュー取得状態に応じて表示を変化
    final body = asyncReview.when(
      data: (review) => ReviewFormWidget(review: review),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        header,
        SizedBox(height: 16),
        body,
      ],
    );
  }
}

// レビューの評価を行う行を表示するウィジェット
class ReviewRatingRow extends HookConsumerWidget {

  final String label;
  final ValueNotifier<int> notifier;

  const ReviewRatingRow({super.key, required this.label, required this.notifier});
  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(width: 80, child: Text(label, overflow: TextOverflow.ellipsis)),
        ...List.generate(5, (i) => IconButton(
          icon: Icon(
            i < notifier.value ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 18,
          ),
          onPressed: () {
            notifier.value = i + 1;
          },
          iconSize: 18,
          padding: EdgeInsets.all(-20), // マイナスパディングでさらに詰める
          constraints: BoxConstraints.tightFor(width: 20, height: 20),
          visualDensity: VisualDensity(horizontal: -4, vertical: -4),
        )),
        SizedBox(width: 2),
        SizedBox(
          width: 5, // 固定幅を設定
          child: Text(
            notifier.value > 0 ? notifier.value.toString() : '',
            textAlign: TextAlign.center, // 中央揃え
          ),
        ),
      ],
    );
  }
}