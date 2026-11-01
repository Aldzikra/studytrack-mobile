import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// Logo StudyTrack. [light] = kotak putih untuk di atas panel biru.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.light = false, this.size = 32});
  final bool light;
  final double size;

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: light ? Colors.white : AppColors.brand,
            borderRadius: BorderRadius.circular(size * 0.29),
          ),
          child: Icon(Icons.check_rounded, size: size * 0.72, color: light ? AppColors.brand : Colors.white),
        ),
        const SizedBox(width: 8),
        Text('StudyTrack',
            style: TextStyle(
              fontSize: light ? 18 : 17,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              color: light ? Colors.white : AppColors.ink,
            )),
      ]);
}
