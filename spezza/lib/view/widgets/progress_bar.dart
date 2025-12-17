import 'package:flutter/material.dart';

class ProgressBarCustom extends StatelessWidget {
  final double progress;
  final double? height;
  final bool showPercentage;
  final Color? barColor;
  final Color? backgroundColor;

  const ProgressBarCustom({
    super.key,
    required this.progress,
    this.height,
    this.showPercentage = true,
    this.barColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? Colors.white70 : Colors.black26;
    final overflowProgress = progress > 1.0;
    final overflowColor = Color(0xFFCC3700);

    return Container(
      height: height ?? 20,
      decoration: BoxDecoration(
        color: backgroundColor ?? color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          FractionallySizedBox(
            widthFactor: progress.clamp(0.0, 1.0),

            child: Container(
              decoration: BoxDecoration(
                color: overflowProgress
                    ? overflowColor
                    : (barColor ?? Color(0xFF008000)),
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
