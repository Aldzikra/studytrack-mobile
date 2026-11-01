import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/api/api_error.dart';
import '../../../core/utils/date_format.dart';
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
    final tt = Theme.of(context).textTheme;
    final radius = BorderRadius.circular(16);

    final content = Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: Text(t.matkulNama,
                  style: tt.labelMedium?.copyWith(color: AppColors.muted), overflow: TextOverflow.ellipsis),
            ),
            _Badge(
              t.selesai ? 'Selesai' : 'Belum',
              t.selesai ? AppColors.selesaiBg : AppColors.belumBg,
              t.selesai ? AppColors.selesaiFg : AppColors.belumFg,
            ),
          ]),
          const SizedBox(height: 6),
          Text(t.judul, style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          if (t.deskripsi.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(t.deskripsi,
                maxLines: 2, overflow: TextOverflow.ellipsis, style: tt.bodySmall?.copyWith(color: AppColors.muted)),
          ],
          const SizedBox(height: 10),
          Row(children: [
            const Icon(Icons.event, size: 16, color: AppColors.muted),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                formatWib(t.deadline),
                style: tt.bodySmall?.copyWith(
                  color: AppColors.muted,
                  decoration: s.strikeDate ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            if (s.badgeColor != null) _Badge(deadlineLabel(t.deadline), s.badgeColor!, Colors.white),
          ]),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: t.selesai
                ? OutlinedButton(onPressed: _busy ? null : _toggle, child: _label('Batalkan'))
                : FilledButton(onPressed: _busy ? null : _toggle, child: _label('Tandai selesai')),
          ),
        ],
      ),
    );

    return CustomPaint(
      foregroundPainter: s.dashed ? _DashedBorder(s.borderColor, radius) : null,
      child: Container(
        decoration: BoxDecoration(
          color: s.background,
          borderRadius: radius,
          border: s.dashed ? null : Border.all(color: s.borderColor, width: s.borderWidth),
        ),
        child: content,
      ),
    );
  }

  Widget _label(String text) => _busy
      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
      : Text(text);
}

class _Badge extends StatelessWidget {
  const _Badge(this.text, this.bg, this.fg);
  final String text;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
        child: Text(text,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: fg, fontWeight: FontWeight.w700)),
      );
}

class _DashedBorder extends CustomPainter {
  _DashedBorder(this.color, this.radius);
  final Color color;
  final BorderRadius radius;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()..addRRect(radius.toRRect(Offset.zero & size));
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (final m in path.computeMetrics()) {
      for (var d = 0.0; d < m.length; d += 10) {
        canvas.drawPath(m.extractPath(d, d + 6), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorder o) => o.color != color || o.radius != radius;
}
