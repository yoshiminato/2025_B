import 'package:flutter/material.dart';

class StarWidget extends StatelessWidget {

  final double? rating;
  const StarWidget({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {

    return 
    // レビューがない場合はレビューなしと表示
    ((rating == null) || (rating == 0)) ?
    const Text("レビューなし",style: TextStyle(fontSize: 10, color: Colors.black54)):
    Row(
      children: [
        // 星アイコン（小数対応）
        for (int i = 1; i <= 5; i++)
          rating! >= i
            ? const Icon(Icons.star, color: Colors.amber, size: 14)
            : (rating! >= i - 0.5
                ? const Icon(Icons.star_half, color: Colors.amber, size: 14)
                : const Icon(Icons.star_border, color: Colors.amber, size: 14)),
        const SizedBox(width: 4),
        Text(
        rating!.toStringAsFixed(1),
          style: const TextStyle(fontSize: 10, color: Colors.black54),
        ),
      ],
    );
  }
}