import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import 'theme.dart';

/// مسافة أسفل الصفحات حتى لا يغطيها شريط التنقل.
const double kNavSpace = 112;

class Hairline extends StatelessWidget {
  const Hairline({super.key});
  @override
  Widget build(BuildContext context) => Container(height: 1, color: context.pal.line);
}

IconData chevronIcon(BuildContext context) =>
    Directionality.of(context) == TextDirection.rtl ? Icons.chevron_left : Icons.chevron_right;

/// صف في قائمة بخط فاصل رفيع.
class RowLink extends StatelessWidget {
  final String title;
  final String? sub;
  final bool accentSub;
  final VoidCallback onTap;
  const RowLink({super.key, required this.title, this.sub, this.accentSub = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 64),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: p.line))),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: NourText.body(17, p.ink, w: FontWeight.w500)),
                  if (sub != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(sub!, style: NourText.body(13, accentSub ? p.accent : p.muted)),
                    ),
                ],
              ),
            ),
            Icon(chevronIcon(context), size: 20, color: p.muted),
          ],
        ),
      ),
    );
  }
}

class ScreenTitle extends StatelessWidget {
  final String text;
  final Widget? trailing;
  const ScreenTitle(this.text, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: Text(text, style: NourText.display(44, p.ink))),
        if (trailing != null) Padding(padding: const EdgeInsets.only(bottom: 6), child: trailing),
      ],
    );
  }
}

/// زر أيقونة بحجم لمس 44.
class IconBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const IconBtn({super.key, required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => IconButton(
        onPressed: onTap,
        tooltip: label,
        icon: Icon(icon, size: 22, color: context.pal.ink),
        constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
      );
}

class AccentButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool outlined;
  const AccentButton({super.key, required this.label, required this.onTap, this.outlined = false});

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          backgroundColor: outlined ? Colors.transparent : p.accent,
          foregroundColor: outlined ? p.ink : p.onAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: outlined ? BorderSide(color: p.line) : BorderSide.none,
          ),
        ),
        child: Text(label, style: NourText.body(16, outlined ? p.ink : p.onAccent, w: FontWeight.w600)),
      ),
    );
  }
}

class NavItem {
  final IconData icon;
  final String label;
  const NavItem(this.icon, this.label);
}

/// نجمة ثمانية من مربعين متراكبين مع نقطة ضوء في المركز (شعار نور).
class StarMark extends StatelessWidget {
  final double size;
  final Color color;
  final Color hole;
  const StarMark({super.key, required this.size, required this.color, required this.hole});

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.square(size), painter: _StarPainter(color, hole));
}

class _StarPainter extends CustomPainter {
  final Color color, hole;
  _StarPainter(this.color, this.hole);

  @override
  void paint(Canvas canvas, Size size) {
    final u = size.width / 100;
    final c = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 * u
      ..strokeJoin = StrokeJoin.round;
    for (final a in [0.0, math.pi / 4]) {
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate(a);
      final r = RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: 40 * u, height: 40 * u), Radius.circular(3 * u));
      canvas.drawRRect(r, paint);
      canvas.drawRRect(r, stroke);
      canvas.restore();
    }
    canvas.drawCircle(c, 13.5 * u, Paint()..color = hole);
    canvas.drawCircle(c, 5.5 * u, paint);
  }

  @override
  bool shouldRepaint(covariant _StarPainter old) => old.color != color || old.hole != hole;
}

/// زخرفة نجمة مفرغة (خطوط رفيعة) للخلفيات.
class StarOutline extends StatelessWidget {
  final double size;
  final Color color;
  const StarOutline({super.key, required this.size, required this.color});

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.square(size), painter: _OutlinePainter(color));
}

class _OutlinePainter extends CustomPainter {
  final Color color;
  _OutlinePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final u = size.width / 100;
    final c = Offset(size.width / 2, size.height / 2);
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6 * u;
    for (final a in [0.0, math.pi / 4]) {
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate(a);
      canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: 60 * u, height: 60 * u), stroke);
      canvas.restore();
    }
    canvas.drawCircle(c, 30 * u, stroke);
    canvas.drawCircle(c, 11.5 * u, stroke);
  }

  @override
  bool shouldRepaint(covariant _OutlinePainter old) => old.color != color;
}

/// عنوان قسم صغير.
class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 28, bottom: 6),
        child: Text(text, style: NourText.body(13, context.pal.accent, w: FontWeight.w600)),
      );
}
