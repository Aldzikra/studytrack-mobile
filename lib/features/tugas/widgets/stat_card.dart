import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.count,
    required this.background,
    required this.border,
    required this.numberColor,
    required this.labelColor,
  });
  final String label;
  final int count;
  final Color background;
  final Color border;
  final Color numberColor;
  final Color labelColor;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('$count', style: TextStyle(fontSize: 22, height: 1.2, fontWeight: FontWeight.w800, color: numberColor)),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: labelColor)),
        ]),
      );
}
