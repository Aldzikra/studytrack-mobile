import 'package:flutter/material.dart';

import '../../../app/theme.dart';

class StatCard extends StatelessWidget {
  const StatCard({super.key, required this.label, required this.count, required this.color});
  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$count', style: t.headlineSmall?.copyWith(fontWeight: FontWeight.w800, color: color)),
          Text(label, style: t.bodySmall?.copyWith(color: AppColors.muted)),
        ],
      ),
    );
  }
}
