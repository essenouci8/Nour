import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../core/common.dart';

/// بطاقة مشاركة: آية أو ذكر كصورة بخط وألوان نور (١٠٨٠×١٣٥٠).
class ShareCardScreen extends StatefulWidget {
  final String text;
  final String source;
  const ShareCardScreen({super.key, required this.text, required this.source});

  @override
  State<ShareCardScreen> createState() => _ShareCardScreenState();
}

class _CardStyle {
  final String nameKey;
  final List<Color> bg;
  final Color ink, accent;
  const _CardStyle(this.nameKey, this.bg, this.ink, this.accent);
}

const _styles = <_CardStyle>[
  _CardStyle('style_paper', [Color(0xFFF8F3E8), Color(0xFFECE4D2)], Color(0xFF14231F), Color(0xFF0E5A47)),
  _CardStyle('style_green', [Color(0xFF16705A), Color(0xFF093A2E)], Color(0xFFF4F0E4), Color(0xFFE3C27A)),
  _CardStyle('style_night', [Color(0xFF14231E), Color(0xFF090F0D)], Color(0xFFEDE7DA), Color(0xFF4FB896)),
];

class _ShareCardScreenState extends State<ShareCardScreen> {
  final _boundary = GlobalKey();
  int _style = 0;
  bool _busy = false;

  Future<void> _share() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final b = _boundary.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final img = await b.toImage(pixelRatio: 3);
      final data = await img.toByteData(format: ui.ImageByteFormat.png);
      final dir = await getTemporaryDirectory();
      final f = File('${dir.path}/nour_card_${DateTime.now().millisecondsSinceEpoch}.png');
      await f.writeAsBytes(data!.buffer.asUint8List());
      await Share.shareXFiles([XFile(f.path, mimeType: 'image/png')]);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('share_failed'))));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final st = _styles[_style];
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 24, 0),
              child: Row(
                children: [
                  IconBtn(icon: Icons.arrow_forward, label: t('back'), onTap: () => Navigator.pop(context)),
                  Expanded(child: Text(t('share_card'), style: NourText.display(28, p.ink))),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 28, offset: const Offset(0, 12)),
                        ],
                      ),
                      child: RepaintBoundary(
                        key: _boundary,
                        child: _Card(style: st, text: widget.text, source: widget.source),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  for (var i = 0; i < _styles.length; i++)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: 10),
                      child: Semantics(
                        button: true,
                        selected: i == _style,
                        label: t(_styles[i].nameKey),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => setState(() => _style = i),
                          child: Container(
                            width: 48,
                            height: 48,
                            alignment: Alignment.center,
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: _styles[i].bg,
                                ),
                                border: Border.all(
                                    color: i == _style ? p.accent : p.muted.withOpacity(0.4), width: i == _style ? 2.5 : 1),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  const Spacer(),
                  Text(t(st.nameKey), style: NourText.body(13, p.muted)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 18),
              child: AccentButton(label: _busy ? t('loading') : t('share'), onTap: _share),
            ),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final _CardStyle style;
  final String text;
  final String source;
  const _Card({required this.style, required this.text, required this.source});

  double get _size {
    final n = text.length;
    if (n < 50) return 34;
    if (n < 110) return 29;
    if (n < 200) return 25;
    if (n < 320) return 21;
    return 18;
  }

  @override
  Widget build(BuildContext context) {
    final s = style;
    return SizedBox(
      width: 360,
      height: 450,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: s.bg),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: DecoratedBox(
                  decoration: BoxDecoration(border: Border.all(color: s.accent.withOpacity(0.38), width: 1)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 34, 30, 28),
              child: Column(
                children: [
                  StarMark(size: 20, color: s.accent, hole: s.bg.first),
                  Expanded(
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: SizedBox(
                          width: 300,
                          child: Text(
                            text,
                            textAlign: TextAlign.center,
                            textDirection: TextDirection.rtl,
                            style: NourText.quran(_size, s.ink).copyWith(height: 2.0),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(width: 36, height: 1, color: s.accent.withOpacity(0.6)),
                  const SizedBox(height: 10),
                  Text(source,
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      style: NourText.body(13, s.ink.withOpacity(0.78))),
                  const SizedBox(height: 4),
                  Text('نور', style: NourText.display(20, s.accent, w: FontWeight.w700)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
