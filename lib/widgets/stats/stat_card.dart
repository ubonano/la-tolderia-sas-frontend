import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? percentage;
  final String? count;
  final double titleSize;
  final double percentageSize;
  final double countSize;
  final Color? titleColor;
  final Color? backgroundColor;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    this.percentage,
    this.count,
    this.titleSize = 16,
    this.percentageSize = 13.6,
    this.countSize = 10.2,
    this.titleColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: IntrinsicWidth(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RichText(
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: title,
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.bold,
                        color: titleColor ?? Colors.grey,
                      ),
                    ),
                    if (percentage != null)
                      TextSpan(
                        text: ' ($percentage%)',
                        style: TextStyle(
                          fontSize: percentageSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    if (count != null)
                      TextSpan(
                        text: ' ($count)',
                        style: TextStyle(
                          fontSize: countSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 