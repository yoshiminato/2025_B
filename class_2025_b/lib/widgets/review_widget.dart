import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:class_2025_b/states/review_state.dart';
import 'package:class_2025_b/models/review_model.dart';
import 'package:class_2025_b/states/user_state.dart';

class ReviewFormWidget extends HookConsumerWidget {
  final Review review;

  const ReviewFormWidget({super.key, required this.review});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final tasteRating = useState(review.tasteRating);
    final easeRating  = useState(review.easeRating);
    final costRating  = useState(review.costRating);
    final uniquenessRating = useState(review.uniquenessRating);

    useEffect(() {
      tasteRating.value = review.tasteRating;
      easeRating.value  = review.easeRating;
      costRating.value  = review.costRating;
      uniquenessRating.value = review.uniquenessRating;
      return null;
    }, [review]);

    final user = ref.watch(userProvider);

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
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Text(
          'レビューを投稿するには、ログインした状態すべての評価を設定してください',
          style: TextStyle(color: Colors.red),
        ),
      ),
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
          } : null,
          child: const Text('レビューを投稿する'),
        )
      )
    ],
  );
  }
}

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


class ReviewRatingRow extends HookConsumerWidget {

  final String label;
  final ValueNotifier<int> notifier;

  const ReviewRatingRow({super.key, required this.label, required this.notifier});
  @override
  Widget build(BuildContext context, WidgetRef ref) {

    debugPrint(notifier.value.toString());

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
        Text(notifier.value > 0 ? notifier.value.toString() : ''),
      ],
    );
  }
}