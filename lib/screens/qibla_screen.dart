import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';

import '../core/common.dart';
import '../core/geo.dart';
import '../data/cities.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});
  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  bool _wasFacing = false;

  static const _compass8 = [
    ['شمال', 'North', 'Nord'],
    ['شمال شرق', 'North-east', 'Nord-est'],
    ['شرق', 'East', 'Est'],
    ['جنوب شرق', 'South-east', 'Sud-est'],
    ['جنوب', 'South', 'Sud'],
    ['جنوب غرب', 'South-west', 'Sud-ouest'],
    ['غرب', 'West', 'Ouest'],
    ['شمال غرب', 'North-west', 'Nord-ouest'],
  ];

  String _dirName(double deg) {
    final i = ((deg + 22.5) % 360) ~/ 45;
    final li = const {'ar': 0, 'en': 1, 'fr': 2}[AppState.instance.lang] ?? 0;
    return _compass8[i][li];
  }

  @override
  Widget build(BuildContext context) {
    final s = AppState.instance;
    final p = context.pal;
    if (!s.hasLocation) return const SizedBox.shrink();
    final q = qiblaBearing(s.lat!, s.lon!);
    final km = distanceToKaabaKm(s.lat!, s.lon!);

    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snap) {
        final heading = snap.data?.heading; // قد تكون null إن لم تتوفر البوصلة
        final diff = heading == null ? 999.0 : (((q - heading + 540) % 360) - 180).abs();
        final facing = diff < 5;
        if (facing && !_wasFacing) HapticFeedback.mediumImpact();
        _wasFacing = facing;

        return ListView(
          padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 24, 24, kNavSpace),
          children: [
            ScreenTitle(t('nav_qibla'),
                trailing: Text(cityLabel(s, t('my_location')), style: NourText.body(13, p.muted))),
            const SizedBox(height: 14),
            Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(color: facing ? p.accent : p.line, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Text(
                  heading == null ? t('compass_unavailable') : (facing ? t('facing_qibla') : t('turn_to_qibla')),
                  style: NourText.body(14, facing ? p.accent : p.muted, w: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Center(
              child: SizedBox(
                width: 300,
                height: 300,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      top: -26,
                      child: Icon(Icons.arrow_drop_down, size: 36, color: p.accent),
                    ),
                    AnimatedRotation(
                      turns: -(heading ?? 0) / 360,
                      duration: const Duration(milliseconds: 180),
                      child: CustomPaint(
                        size: const Size(300, 300),
                        painter: _DialPainter(
                          qibla: q,
                          ink: p.ink,
                          muted: p.muted,
                          accent: p.accent,
                          fill: p.surface,
                          line: p.line,
                          letters: _letters(),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(nd('${q.round()}°'), style: NourText.body(52, p.ink, w: FontWeight.w300, h: 1)),
                        const SizedBox(height: 4),
                        Text(t('from_north'), style: NourText.body(13, p.muted)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 44),
            const Hairline(),
            _kv(p, t('direction'), _dirName(q)),
            _kv(p, t('distance_kaaba'), '${nd(km.round().toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ','))} ${t('km')}'),
            if (heading == null)
              Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Text(t('compass_hint'), style: NourText.body(13, p.muted, h: 1.7)),
              ),
          ],
        );
      },
    );
  }

  List<String> _letters() {
    switch (AppState.instance.lang) {
      case 'en':
        return ['N', 'E', 'S', 'W'];
      case 'fr':
        return ['N', 'E', 'S', 'O'];
      default:
        return ['ش', 'ق', 'ج', 'غ'];
    }
  }

  Widget _kv(NourPalette p, String k, String v) => Container(
        height: 56,
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: p.line))),
        child: Row(
          children: [
            Expanded(child: Text(k, style: NourText.body(15, p.muted))),
            Text(v, style: NourText.body(16, p.ink, w: FontWeight.w500)),
          ],
        ),
      );
}

class _DialPainter extends CustomPainter {
  final double qibla;
  final Color ink, muted, accent, fill, line;
  final List<String> letters;
  _DialPainter({
    required this.qibla,
    required this.ink,
    required this.muted,
    required this.accent,
    required this.fill,
    required this.line,
    required this.letters,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2 - 2;
    canvas.drawCircle(c, r, Paint()..color = fill);
    canvas.drawCircle(
        c,
        r,
        Paint()
          ..color = line
          ..style = PaintingStyle.stroke);

    for (var i = 0; i < 72; i++) {
      final major = i % 6 == 0;
      final a = i * 5 * math.pi / 180;
      final len = major ? 16.0 : 10.0;
      final p1 = c + Offset(math.sin(a), -math.cos(a)) * (r - 4);
      final p2 = c + Offset(math.sin(a), -math.cos(a)) * (r - 4 - len);
      canvas.drawLine(
        p1,
        p2,
        Paint()
          ..color = major ? ink.withOpacity(0.7) : ink.withOpacity(0.28)
          ..strokeWidth = major ? 1.6 : 1,
      );
    }

    for (var i = 0; i < 4; i++) {
      final a = i * math.pi / 2;
      final pos = c + Offset(math.sin(a), -math.cos(a)) * (r - 40);
      final tp = TextPainter(
        text: TextSpan(
          text: letters[i],
          style: NourText.body(i == 0 ? 17 : 15, i == 0 ? accent : muted, w: i == 0 ? FontWeight.w600 : FontWeight.w400),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(a);
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }

    // الكعبة عند زاوية القبلة
    final qa = qibla * math.pi / 180;
    final kp = c + Offset(math.sin(qa), -math.cos(qa)) * (r - 4);
    canvas.drawLine(
        c + Offset(math.sin(qa), -math.cos(qa)) * 60,
        c + Offset(math.sin(qa), -math.cos(qa)) * (r - 26),
        Paint()
          ..color = accent
          ..strokeWidth = 1.5);
    canvas.save();
    canvas.translate(kp.dx, kp.dy);
    canvas.rotate(qa);
    final box = RRect.fromRectAndRadius(Rect.fromCenter(center: const Offset(0, 4), width: 22, height: 22), const Radius.circular(4));
    canvas.drawRRect(box, Paint()..color = ink);
    canvas.drawRect(Rect.fromLTWH(-11, -1, 22, 4), Paint()..color = const Color(0xFFC9A24B));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _DialPainter old) =>
      old.qibla != qibla || old.ink != ink || old.accent != accent || old.fill != fill;
}
