import 'package:flutter/services.dart';

import '../core/common.dart';
import '../data/adhkar.dart';
import 'share_card.dart';

/// تبويب الأذكار: المسبحة، الأذكار اليومية، الأدعية.
class AdhkarScreen extends StatefulWidget {
  const AdhkarScreen({super.key});
  @override
  State<AdhkarScreen> createState() => _AdhkarScreenState();
}

class _AdhkarScreenState extends State<AdhkarScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final tabs = [t('tasbih'), t('adhkar_daily'), t('duas')];
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) => ListView(
        padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 24, 24, kNavSpace),
        children: [
          ScreenTitle(t('nav_adhkar')),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: p.line))),
            child: Row(
              children: [
                for (var i = 0; i < tabs.length; i++) ...[
                  if (i > 0) const SizedBox(width: 22),
                  InkWell(
                    onTap: () => setState(() => _tab = i),
                    child: Container(
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(color: i == _tab ? p.accent : Colors.transparent, width: 2)),
                      ),
                      child: Text(tabs[i],
                          style: NourText.body(15, i == _tab ? p.accent : p.muted,
                              w: i == _tab ? FontWeight.w600 : FontWeight.w400)),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (_tab == 0) const _Tasbih(),
          if (_tab == 1) ..._groups(context),
          if (_tab == 2) ..._duas(context),
        ],
      ),
    );
  }

  List<Widget> _groups(BuildContext context) => [
        for (final g in kAdhkar)
          RowLink(
            title: t('g_${g.id}'),
            sub: '${nd(g.items.length)} ${t('adhkar_count')}',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DhikrScreen(group: g))),
          ),
      ];

  List<Widget> _duas(BuildContext context) {
    final p = context.pal;
    return [
      for (final d in kDuas)
        Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: p.line))),
          child: Row(
            children: [
              Expanded(
                child: Text(d, textDirection: TextDirection.rtl, style: NourText.quran(24, p.ink).copyWith(height: 2)),
              ),
              IconBtn(
                icon: Icons.copy,
                label: t('copy'),
                onTap: () => Clipboard.setData(ClipboardData(text: d)),
              ),
            ],
          ),
        ),
    ];
  }
}

/// المسبحة: ثلاثة أذكار 33/33/34، العدّاد يحفظ مجموع اليوم.
class _Tasbih extends StatefulWidget {
  const _Tasbih();
  @override
  State<_Tasbih> createState() => _TasbihState();
}

class _TasbihState extends State<_Tasbih> {
  static const _targets = [33, 33, 34];
  static const _zikr = ['سُبْحَانَ ٱللَّهِ', 'ٱلْحَمْدُ لِلَّهِ', 'ٱللَّهُ أَكْبَرُ'];
  int _sel = 0;
  int _count = 0;

  void _tap() {
    HapticFeedback.selectionClick();
    AppState.instance.addTasbih();
    setState(() {
      if (_count >= _targets[_sel]) {
        _sel = (_sel + 1) % 3;
        _count = 1;
        HapticFeedback.mediumImpact();
      } else {
        _count++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final tg = _targets[_sel];
    final done = _count >= tg;
    return Column(
      children: [
        const SizedBox(height: 20),
        Row(
          children: [
            for (var i = 0; i < 3; i++) ...[
              if (i > 0) const SizedBox(width: 18),
              InkWell(
                onTap: () => setState(() {
                  _sel = i;
                  _count = 0;
                }),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 44),
                  child: Center(
                    child: Text(_labels[i],
                        style: NourText.body(14, i == _sel ? p.accent : p.muted,
                            w: i == _sel ? FontWeight.w600 : FontWeight.w400)),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 14),
        Semantics(
          button: true,
          label: '${t('tasbih')} $_count',
          child: GestureDetector(
            onTap: _tap,
            child: SizedBox(
              width: 260,
              height: 260,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(260, 260),
                    painter: _RingPainter(_count / tg, p.accent, p.line, p.surface),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_zikr[_sel], style: NourText.quran(30, p.ink).copyWith(height: 1.5)),
                      Text(nd(_count), style: NourText.body(68, p.ink, w: FontWeight.w300, h: 1.05)),
                      const SizedBox(height: 4),
                      Text(done ? t('tasbih_done') : '${t('of')} ${nd(tg)}', style: NourText.body(14, p.muted)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.only(top: 14),
          decoration: BoxDecoration(border: Border(top: BorderSide(color: p.line))),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t('total_today'), style: NourText.body(13, p.muted)),
                    Text(nd(AppState.instance.tasbihToday), style: NourText.body(22, p.ink, w: FontWeight.w500)),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _count = 0),
                style: TextButton.styleFrom(minimumSize: const Size(44, 44)),
                child: Text(t('reset'), style: NourText.body(15, p.accent, w: FontWeight.w500)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<String> get _labels => const ['سبحان الله', 'الحمد لله', 'الله أكبر'];
}

class _RingPainter extends CustomPainter {
  final double value;
  final Color accent, track, fill;
  _RingPainter(this.value, this.accent, this.track, this.fill);

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2 - 4;
    canvas.drawCircle(c, r, Paint()..color = fill);
    canvas.drawCircle(
        c,
        r,
        Paint()
          ..color = track
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1);
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -1.5707963,
      6.2831853 * value.clamp(0.0, 1.0),
      false,
      Paint()
        ..color = accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.value != value || old.accent != accent;
}

class DhikrScreen extends StatefulWidget {
  final DhikrGroup group;
  const DhikrScreen({super.key, required this.group});
  @override
  State<DhikrScreen> createState() => _DhikrScreenState();
}

class _DhikrScreenState extends State<DhikrScreen> {
  late final List<int> _left = [for (final d in widget.group.items) d.count];

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final items = widget.group.items;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 24, 0),
              child: Row(
                children: [
                  IconBtn(icon: Icons.arrow_forward, label: t('back'), onTap: () => Navigator.pop(context)),
                  Expanded(child: Text(t('g_${widget.group.id}'), style: NourText.display(30, p.ink))),
                  TextButton(
                    onPressed: () => setState(() {
                      for (var i = 0; i < items.length; i++) {
                        _left[i] = items[i].count;
                      }
                    }),
                    child: Text(t('reset'), style: NourText.body(14, p.accent, w: FontWeight.w500)),
                  ),
                ],
              ),
            ),
            const Hairline(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: items.length,
                itemBuilder: (_, i) {
                  final done = _left[i] == 0;
                  return InkWell(
                    onTap: () {
                      if (_left[i] > 0) {
                        HapticFeedback.selectionClick();
                        setState(() => _left[i]--);
                      }
                    },
                    child: Opacity(
                      opacity: done ? 0.45 : 1,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: p.line))),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(items[i].text,
                                textDirection: TextDirection.rtl,
                                style: NourText.quran(24, p.ink).copyWith(height: 2)),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Icon(done ? Icons.check_circle : Icons.radio_button_unchecked,
                                    size: 18, color: done ? p.accent : p.muted),
                                const SizedBox(width: 8),
                                Text(
                                  done
                                      ? t('done')
                                      : '${t('remaining')} ${nd(_left[i])} ${t('of')} ${nd(items[i].count)}',
                                  style: NourText.body(13, done ? p.accent : p.muted),
                                ),
                                const Spacer(),
                                IconButton(
                                  tooltip: t('share_card'),
                                  visualDensity: VisualDensity.compact,
                                  constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                                  icon: Icon(Icons.ios_share, size: 20, color: p.muted),
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ShareCardScreen(
                                          text: items[i].text, source: t('g_${widget.group.id}')),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
