import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// Pesan tengah layar (empty/error) yang tetap bisa di-pull-to-refresh.
class MessageView extends StatelessWidget {
  const MessageView({super.key, required this.icon, required this.text, this.action});
  final IconData icon;
  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (_, c) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: c.maxHeight,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(icon, size: 48, color: AppColors.muted),
                  const SizedBox(height: 12),
                  Text(text, textAlign: TextAlign.center),
                  if (action != null) ...[const SizedBox(height: 16), action!],
                ]),
              ),
            ),
          ),
        ),
      );
}
