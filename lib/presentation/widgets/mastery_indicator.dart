import 'package:flutter/material.dart';
import '../../domain/models/progress_model.dart';

class MasteryIndicator extends StatelessWidget {
  final WordProgress? progress;
  final bool showCount;

  const MasteryIndicator({super.key, this.progress, this.showCount = true});

  @override
  Widget build(BuildContext context) {
    final correct = progress?.timesCorrect ?? 0;
    final mastered = progress?.isMastered ?? false;
    final color = mastered
        ? Colors.amber[600]!
        : correct > 0
            ? Colors.amber[300]!
            : Colors.grey[300]!;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(mastered ? Icons.star_rounded : Icons.star_outline_rounded,
            size: 16, color: color),
        if (showCount && correct > 0) ...[
          const SizedBox(width: 2),
          Text(
            '$correct',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
