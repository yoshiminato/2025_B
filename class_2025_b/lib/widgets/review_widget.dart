import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ReviewWidget extends HookConsumerWidget {

  const ReviewWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReviewRatingRow(label: '味'),
        SizedBox(height: 16),
        ReviewRatingRow(label: '作りやすさ'),
        SizedBox(height: 16),
        ReviewRatingRow(label: 'コスパ'),
        SizedBox(height: 16),
        Center(
          child: ElevatedButton(
            onPressed: null, 
            child: const Text('レビューを投稿する'),
          )
        )
      ],
    );
  }
}


class ReviewRatingRow extends HookConsumerWidget {
  final String label;

  const ReviewRatingRow({super.key, required this.label});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rating = useState(0);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(width: 80, child: Text(label, overflow: TextOverflow.ellipsis)),
        ...List.generate(5, (i) => IconButton(
          icon: Icon(
            i < rating.value ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 18,
          ),
          onPressed: () {
            rating.value = i + 1;
          },
          iconSize: 18,
          padding: EdgeInsets.all(-20), // マイナスパディングでさらに詰める
          constraints: BoxConstraints.tightFor(width: 20, height: 20),
          visualDensity: VisualDensity(horizontal: -4, vertical: -4),
        )),
        SizedBox(width: 2),
        Text(rating.value > 0 ? rating.value.toString() : ''),
      ],
    );
  }
}