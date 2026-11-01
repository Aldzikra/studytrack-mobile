import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Port dari motion/animasi web (index.css + AuthShell). Semua animasi mati
/// bila pengaturan "kurangi animasi" di HP aktif (MediaQuery.disableAnimations).
bool reduceMotion(BuildContext context) => MediaQuery.disableAnimationsOf(context);

/// Animasi masuk sekali: fade + geser + skala + rotasi dari keadaan awal ke normal.
/// Sebelum [delay] selesai, child tetap di keadaan awal (setara `backwards` di CSS).
class Entrance extends StatefulWidget {
  const Entrance({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 350),
    this.delay = Duration.zero,
    this.curve = Curves.easeOut,
    this.offset = Offset.zero,
    this.scale = 1,
    this.fromRotation = 0,
    this.toRotation = 0,
  });

  final Widget child;
  final Duration duration;
  final Duration delay;
  final Curve curve;
  final Offset offset; // posisi awal relatif ke posisi akhir (px)
  final double scale; // skala awal
  final double fromRotation; // radian
  final double toRotation; // radian

  @override
  State<Entrance> createState() => _EntranceState();
}

class _EntranceState extends State<Entrance> with SingleTickerProviderStateMixin {
  late final Duration _total = widget.delay + widget.duration;
  late final AnimationController _c = AnimationController(vsync: this, duration: _total);
  late final Animation<double> _t = CurvedAnimation(
    parent: _c,
    curve: Interval(widget.delay.inMicroseconds / _total.inMicroseconds, 1, curve: widget.curve),
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started && !reduceMotion(context)) {
      _started = true;
      _c.forward();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (reduceMotion(context)) return widget.child;
    return AnimatedBuilder(
      animation: _t,
      child: widget.child,
      builder: (_, child) {
        final v = _t.value; // bisa >1 pada kurva overshoot (pop)
        return Opacity(
          opacity: v.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset.lerp(widget.offset, Offset.zero, v)!,
            child: Transform.rotate(
              angle: widget.fromRotation + (widget.toRotation - widget.fromRotation) * v,
              child: Transform.scale(scale: widget.scale + (1 - widget.scale) * v, child: child),
            ),
          ),
        );
      },
    );
  }
}

/// fade-up: opacity 0→1 + naik dari bawah, 350ms easeOut.
class FadeUp extends StatelessWidget {
  const FadeUp({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 350),
    this.distance = 10,
  });

  /// Stagger per item: 50ms × index, maksimal 8 (seperti TaskCard web).
  FadeUp.item({super.key, required this.child, required int index})
      : delay = Duration(milliseconds: math.min(index, 8) * 50),
        duration = const Duration(milliseconds: 350),
        distance = 10;

  final Widget child;
  final Duration delay;
  final Duration duration;
  final double distance;

  @override
  Widget build(BuildContext context) =>
      Entrance(delay: delay, duration: duration, offset: Offset(0, distance), child: child);
}

/// pop: skala 0.6→1 dengan overshoot, 300ms, delay 200ms.
class Pop extends StatelessWidget {
  const Pop({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Entrance(
        delay: const Duration(milliseconds: 200),
        duration: const Duration(milliseconds: 300),
        curve: const Cubic(0.34, 1.56, 0.64, 1),
        scale: 0.6,
        child: child,
      );
}

/// Mengecil sedikit (0.97) saat ditekan. Memakai Listener sehingga tidak
/// mengganggu gestur tombol di dalamnya.
class PressScale extends StatefulWidget {
  const PressScale({super.key, required this.child, this.scale = 0.97});
  final Widget child;
  final double scale;

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  bool _down = false;

  void _set(bool v) => setState(() => _down = v);

  @override
  Widget build(BuildContext context) {
    final reduce = reduceMotion(context);
    return Listener(
      onPointerDown: (_) => _set(true),
      onPointerUp: (_) => _set(false),
      onPointerCancel: (_) => _set(false),
      child: AnimatedScale(
        scale: _down && !reduce ? widget.scale : 1,
        duration: reduce ? Duration.zero : const Duration(milliseconds: 100),
        child: widget.child,
      ),
    );
  }
}
