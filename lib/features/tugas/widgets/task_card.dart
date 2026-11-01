import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../core/api/api_error.dart';
import '../../../core/utils/date_format.dart';
import '../../../shared/motion/motion.dart';
import '../tugas.dart';
import '../tugas_repository.dart';
import '../tugas_style.dart';

class TaskCard extends ConsumerStatefulWidget {
  const TaskCard({super.key, required this.tugas});
  final Tugas tugas;

  @override
  ConsumerState<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends ConsumerState<TaskCard> {
  bool _busy = false;

  Future<void> _toggle() async {
    final t = widget.tugas;
    setState(() => _busy = true);
    try {
      await ref.read(tugasRepositoryProvider).setStatus(
          t.id, t.selesai ? TugasStatus.belum : TugasStatus.selesai);
      ref.invalidate(tugasListProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(parseApiError(e))));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.tugas;
    final s = styleFor(cardKind(t));
    final radius = BorderRadius.circular(16);

    final content = Padding(
      // total 16 termasuk border (desain: padding 15 + border 2px).
      padding: EdgeInsets.all(16 - (s.dashed ? 1 : s.borderWidth)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Wrap(spacing: 6, runSpacing: 6, children: [
          if (s.badgeColor != null)
            _Badge(
              deadlineLabel(t.deadline),
              s.badgeColor!,
              Colors.white,
              icon: cardKind(t) == TugasCardKind.mendekati ? Icons.alarm : Icons.error_outline,
            ),
          if (t.selesai)
            const _Badge('Selesai', AppColors.selesaiBg, AppColors.selesaiFg, icon: Icons.check)
          else
            const _Badge('Belum', AppColors.belumBg, AppColors.belumFg),
        ]),
        const SizedBox(height: 8),
        Text(t.judul, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: s.titleColor)),
        const SizedBox(height: 8),
        Text(t.matkulNama, style: const TextStyle(fontSize: 13, color: AppColors.muted)),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: Text(
              formatWibShort(t.deadline),
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: s.dateWeight,
                color: s.dateColor,
                decoration: s.strikeDate ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          PressScale(
            child: IconButton(
              tooltip: 'Ubah ${t.judul}',
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              onPressed: () => context.push('/tugas/form', extra: t),
              icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.muted),
            ),
          ),
          const SizedBox(width: 4),
          PressScale(
            child: OutlinedButton(
              onPressed: _busy ? null : _toggle,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(44, 44),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                foregroundColor: s.buttonColor,
                backgroundColor: Colors.white,
                side: BorderSide(color: s.buttonBorder),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
              child: _busy
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(t.selesai ? 'Batalkan' : 'Tandai selesai'),
            ),
          ),
        ]),
      ]),
    );

    return CustomPaint(
      foregroundPainter: s.dashed ? _DashedBorder(s.borderColor, radius) : null,
      child: Container(
        decoration: BoxDecoration(
          color: s.background,
          borderRadius: radius,
          boxShadow: s.shadow,
          border: s.dashed ? Border.all(color: Colors.transparent) : Border.all(color: s.borderColor, width: s.borderWidth),
        ),
        child: content,
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.text, this.bg, this.fg, {this.icon});
  final String text;
  final Color bg;
  final Color fg;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[Icon(icon, size: 13, color: fg), const SizedBox(width: 5)],
          Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: fg)),
        ]),
      );
}

class _DashedBorder extends CustomPainter {
  _DashedBorder(this.color, this.radius);
  final Color color;
  final BorderRadius radius;

  @override
  void paint(Canvas canvas, Size size) {
    // inset 0.5 agar garis 1px tepat di tepi kotak.
    final path = Path()..addRRect(radius.toRRect(Offset.zero & size).deflate(0.5));
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (final m in path.computeMetrics()) {
      for (var d = 0.0; d < m.length; d += 7) {
        canvas.drawPath(m.extractPath(d, d + 4), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorder o) => o.color != color || o.radius != radius;
}
