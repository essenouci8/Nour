import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';

import 'theme.dart';
import 'widgets.dart' show NavItem;

/// شريط التنقل: فقاعات زجاجية منفصلة، وقطرة سائلة تنتقل بينها.
/// عند القفز لزرّ بعيد تتمدّد القطرة وتدفع الفقاعات التي في طريقها ثم تستقر بنبضة.
/// القطرة شفافة (تمويه لما خلفها) وأيقونتها وعنوانها يُرسمان فوقها دائمًا.
class GlassNav extends StatefulWidget {
  final int index;
  final ValueChanged<int> onTap;
  final List<NavItem> items;
  const GlassNav({super.key, required this.index, required this.onTap, required this.items});

  @override
  State<GlassNav> createState() => _GlassNavState();
}

class _GlassNavState extends State<GlassNav> with SingleTickerProviderStateMixin {
  static const double _h = 76;
  static const double _bubble = 52;

  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController.unbounded(vsync: this, value: widget.index.toDouble());
  }

  @override
  void didUpdateWidget(GlassNav old) {
    super.didUpdateWidget(old);
    if (old.index != widget.index) {
      _c.animateWith(SpringSimulation(
        const SpringDescription(mass: 1, stiffness: 200, damping: 15),
        _c.value,
        widget.index.toDouble(),
        _c.velocity,
      ));
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final n = widget.items.length;

    return SizedBox(
      height: _h,
      child: LayoutBuilder(builder: (context, box) {
        final w = box.maxWidth;
        final sw = w / n;
        double cx(double idx) => rtl ? w - (idx + 0.5) * sw : (idx + 0.5) * sw;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            ExcludeSemantics(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _c,
                  builder: (context, _) {
                    final pos = _c.value;
                    final v = _c.velocity;
                    final s = (v.abs() / 8).clamp(0.0, 1.0).toDouble();
                    final dir = v >= 0 ? 1.0 : -1.0;
                    final side = rtl ? -1.0 : 1.0;

                    final dropW = sw + 14 + s * 46;
                    final dropH = 64 - s * 8;
                    final nearest = pos.round().clamp(0, n - 1);

                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        for (var i = 0; i < n; i++) _bubbleAt(p, i, pos, s, dir, side, cx(i.toDouble())),
                        Positioned(
                          left: cx(pos) - dropW / 2,
                          top: (_h - dropH) / 2,
                          width: dropW,
                          height: dropH,
                          child: _drop(p, dropW, dropH, s, nearest),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            // مناطق اللمس والوصول
            Row(
              children: [
                for (var i = 0; i < n; i++)
                  Expanded(
                    child: Semantics(
                      button: true,
                      selected: i == widget.index,
                      label: widget.items[i].label,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          if (i != widget.index) HapticFeedback.selectionClick();
                          widget.onTap(i);
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ],
        );
      }),
    );
  }

  Widget _bubbleAt(NourPalette p, int i, double pos, double s, double dir, double side, double cx) {
    final d = pos - i;
    final push = math.exp(-d * d / 0.30) * s; // اصطدام القطرة بالفقاعة
    final close = math.exp(-d * d / 0.22).clamp(0.0, 1.0).toDouble();
    final dx = dir * side * push * 10;
    final dy = push * 8;
    final scale = 1 - 0.18 * push;

    final fill = p.dark ? Colors.white.withOpacity(0.07) : Colors.white.withOpacity(0.42);
    return Positioned(
      left: cx - _bubble / 2 + dx,
      top: (_h - _bubble) / 2 + dy,
      width: _bubble,
      height: _bubble,
      child: Transform.scale(
        scale: scale,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(p.dark ? 0.35 : 0.10), blurRadius: 16, offset: const Offset(0, 6)),
            ],
          ),
          child: ClipOval(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: CustomPaint(
                foregroundPainter: _RimPainter(dark: p.dark, strength: 0.7),
                child: Container(
                  decoration: BoxDecoration(shape: BoxShape.circle, color: fill),
                  alignment: Alignment.center,
                  // الأيقونة تخفت عندما تقترب القطرة لأنها ترسم الأيقونة النشطة بنفسها
                  child: Opacity(
                    opacity: (1 - close).clamp(0.0, 1.0).toDouble(),
                    child: Icon(widget.items[i].icon, size: 22, color: p.muted),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _drop(NourPalette p, double w, double h, double s, int nearest) {
    // شفافة: تمويه خفيف لما خلفها مع تلوين أبيض رقيق
    final tintTop = p.dark ? Colors.white.withOpacity(0.16) : Colors.white.withOpacity(0.55);
    final tintBottom = p.dark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.18);
    final labelOpacity = (1 - s * 1.6).clamp(0.0, 1.0).toDouble();

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(h / 2),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(p.dark ? 0.45 : 0.16), blurRadius: 22, offset: const Offset(0, 8)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(h / 2),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 9, sigmaY: 9),
          child: CustomPaint(
            foregroundPainter: _RimPainter(dark: p.dark, strength: 1.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [tintTop, tintBottom],
                ),
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(widget.items[nearest].icon, size: 23, color: p.accent),
                  SizedBox(height: 3 * labelOpacity),
                  SizedBox(
                    height: 12 * labelOpacity,
                    child: Opacity(
                      opacity: labelOpacity,
                      child: Text(
                        widget.items[nearest].label,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.clip,
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: p.accent, height: 1.1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// حافة زجاجية: وهج علوي أيسر وانعكاس سفلي أيمن.
class _RimPainter extends CustomPainter {
  final bool dark;
  final double strength;
  _RimPainter({required this.dark, required this.strength});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(size.shortestSide / 2)).deflate(0.8);

    canvas.drawRRect(
      rr,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = Colors.black.withOpacity(dark ? 0.35 : 0.07),
    );

    final a = (dark ? 0.55 : 0.95) * strength;
    canvas.drawRRect(
      rr.deflate(0.6),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(a),
            Colors.white.withOpacity(0),
            Colors.white.withOpacity(0),
            Colors.white.withOpacity(a * 0.55),
          ],
          stops: const [0, 0.38, 0.62, 1],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant _RimPainter old) => old.dark != dark || old.strength != strength;
}
