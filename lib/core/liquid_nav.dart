import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';

import 'theme.dart';
import 'widgets.dart' show NavItem;

/// شريط التنقل: فقاعات زجاجية منفصلة، وقطرة عدسية سائلة تنتقل بينها.
/// عند القفز لزرّ بعيد تتمدّد القطرة وتدفع الفقاعات التي في طريقها ثم تستقر بنبضة.
/// الانكسار الحقيقي بـ fragment shader (Impeller)، وبديله تمويه عادي.
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

  // ضبط المظهر: عدّل هذه القيم بعد التجربة على الهاتف.
  static const double _refractStrength = 1.0;
  static const double _edgeWidth = 20; // سُمك منطقة الانكسار
  static const double _aberration = 0.7;

  late final AnimationController _c;
  ui.FragmentShader? _shader;
  final _navKey = GlobalKey();

  // وضع معايرة الشيدر: اضغط مطولًا على الشريط للتبديل بين 0..4
  // 0 محلي منطقي | 1 محلي فيزيائي | 2 عام فيزيائي | 3 محلي فيزيائي مقلوب | 4 عام مقلوب
  int _mode = 1;

  @override
  void initState() {
    super.initState();
    _c = AnimationController.unbounded(vsync: this, value: widget.index.toDouble());
    _loadShader();
  }

  Future<void> _loadShader() async {
    try {
      if (!ui.ImageFilter.isShaderFilterSupported) return;
      final prog = await ui.FragmentProgram.fromAsset('shaders/lens.frag');
      if (mounted) setState(() => _shader = prog.fragmentShader());
    } catch (_) {
      // يبقى البديل (تمويه)
    }
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
    _shader?.dispose();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final n = widget.items.length;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onLongPress: () {
        setState(() => _mode = (_mode + 1) % 5);
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(duration: const Duration(seconds: 2), content: Text('shader mode $_mode')));
      },
      child: SizedBox(
      key: _navKey,
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
                        for (var i = 0; i < n; i++)
                          _bubbleAt(p, i, pos, s, dir, side, cx(i.toDouble())),
                        Positioned(
                          left: cx(pos) - dropW / 2,
                          top: (_h - dropH) / 2,
                          width: dropW,
                          height: dropH,
                          child: _drop(p, dropW, dropH, s, nearest, cx(pos) - dropW / 2, (_h - dropH) / 2),
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
    ),
    );
  }

  Widget _bubbleAt(NourPalette p, int i, double pos, double s, double dir, double side, double cx) {
    final d = pos - i;
    final push = math.exp(-d * d / 0.30) * s; // اصطدام القطرة بالفقاعة
    final close = math.exp(-d * d / 0.22).clamp(0.0, 1.0).toDouble();
    final dx = dir * side * push * 10;
    final dy = push * 8;
    final scale = 1 - 0.18 * push;
    final iconColor = Color.lerp(p.muted, p.accent, close)!;

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
                  child: Icon(widget.items[i].icon, size: 22, color: iconColor),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _drop(NourPalette p, double w, double h, double s, int nearest, double left, double top) {
    ui.ImageFilter filter;
    final sh = _shader;
    if (sh != null) {
      final mq = MediaQuery.of(context);
      final dpr = mq.devicePixelRatio;
      final global = _mode == 2 || _mode == 4;
      final phys = _mode != 0;
      final k = phys ? dpr : 1.0;
      var ox = 0.0, oy = 0.0;
      var tw = w * k, th = h * k;
      if (global) {
        final rb = _navKey.currentContext?.findRenderObject() as RenderBox?;
        final o = (rb != null && rb.attached) ? rb.localToGlobal(Offset.zero) : Offset.zero;
        ox = (o.dx + left) * dpr;
        oy = (o.dy + top) * dpr;
        tw = mq.size.width * dpr;
        th = mq.size.height * dpr;
      }
      sh
        ..setFloat(0, w * k)
        ..setFloat(1, h * k)
        ..setFloat(2, ox)
        ..setFloat(3, oy)
        ..setFloat(4, tw)
        ..setFloat(5, th)
        ..setFloat(6, (_mode == 3 || _mode == 4) ? 1.0 : 0.0)
        ..setFloat(7, _refractStrength * (0.85 + 0.35 * s))
        ..setFloat(8, _edgeWidth)
        ..setFloat(9, _aberration)
        ..setFloat(10, k);
      filter = ui.ImageFilter.shader(sh);
    } else {
      filter = ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10);
    }

    final tint = p.dark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.10);
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
          filter: filter,
          child: CustomPaint(
            foregroundPainter: _RimPainter(dark: p.dark, strength: 1.0),
            child: Container(
              color: tint,
              alignment: Alignment.bottomCenter,
              padding: const EdgeInsets.only(bottom: 5),
              child: Opacity(
                opacity: (1 - s * 1.6).clamp(0.0, 1.0).toDouble(),
                child: Text(
                  widget.items[nearest].label,
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: p.accent, height: 1.1),
                ),
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
