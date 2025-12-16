import 'package:flutter/material.dart';

class ProgressBarCustom extends StatelessWidget {
  final double progress;
  final double? height;
  final bool showPercentage;

  const ProgressBarCustom({
    super.key,
    required this.progress,
    this.height,
    this.showPercentage = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? Colors.white70 : Colors.black26;
    final overflowProgress = progress > 1.0;
    final overflowColor = Color(0xFFCD3400);

    return Container(
      height: height ?? 20,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          FractionallySizedBox(
            widthFactor: progress.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: overflowProgress ? overflowColor : Color(0xFF008000),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Center(
            child: showPercentage
                ? Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
