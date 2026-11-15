import 'dart:async';
import 'dart:ui' show FontFeature;

import '../core/common.dart';
import '../core/hijri.dart';
import '../services/prayer_service.dart';
import 'khatma_screen.dart';
import 'zakat_screen.dart';

class RamadanScreen extends StatefulWidget {
  const RamadanScreen({super.key});
  @override
  State<RamadanScreen> createState() => _RamadanScreenState();
}

class _RamadanScreenState extends State<RamadanScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppState.instance;
    final p = context.pal;
    final now = DateTime.now();
    final ram = ramadanInfo(now, s.hijriAdjust);
    final day = s.hasLocation ? computeDay(s.lat!, s.lon!, now, s.method) : null;

    // قبل الفجر: العدّ إلى الإمساك. بعده: العدّ إلى الإفطار.
    String label = '';
    Duration? left;
    double prog = 0;
    if (ram.inRamadan && day != null) {
      final fajr = day[PrayerId.fajr], maghrib = day[PrayerId.maghrib];
      if (now.isBefore(fajr)) {
        label = t('imsak_in');
        left = fajr.difference(now);
      } else if (now.isBefore(maghrib)) {
        label = t('iftar_in');
        left = maghrib.difference(now);
        prog = (now.difference(fajr).inSeconds / maghrib.difference(fajr).inSeconds).clamp(0.0, 1.0).toDouble();
      } else {
        label = t('taqabbal');
        prog = 1;
      }
    }

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 32),
          children: [
            Row(
              children: [
                IconBtn(icon: Icons.arrow_forward, label: t('back'), onTap: () => Navigator.pop(context)),
                Expanded(
                  child: Text(
                    ram.inRamadan ? t('ramadan_day').replaceAll('{n}', nd(ram.day)) : t('ramadan_in').replaceAll('{n}', nd(ram.daysTo)),
                    textAlign: TextAlign.end,
                    style: NourText.body(13, p.muted),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(t('ramadan_kareem'), style: NourText.display(56, p.ink)),
            const SizedBox(height: 28),
            if (ram.inRamadan && day != null) ...[
              Text(label, style: NourText.body(14, p.muted)),
              if (left != null)
                Text(fmtDuration(left),
                    style: NourText.body(62, p.accent, w: FontWeight.w300, h: 1.05)
                        .copyWith(fontFeatures: const [FontFeature.tabularFigures()])),
              const SizedBox(height: 22),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: Stack(children: [
                  Container(height: 3, color: p.line),
                  FractionallySizedBox(widthFactor: prog, child: Container(height: 3, color: p.accent)),
                ]),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: Text('${t('imsak')} ${fmtTime(day[PrayerId.fajr])}', style: NourText.body(14, p.muted))),
                  Text('${t('iftar')} ${fmtTime(day[PrayerId.maghrib])}', style: NourText.body(14, p.muted)),
                ],
              ),
              if (ram.day >= 21)
                Padding(
                  padding: const EdgeInsets.only(top: 18),
                  child: Text(t('last_ten'), style: NourText.body(14, p.accent, h: 1.7)),
                ),
            ] else ...[
              Text(t('ramadan_not_yet'), style: NourText.body(16, p.muted, h: 1.8)),
            ],
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(child: Text(t('fasting_days'), style: NourText.body(17, p.ink, w: FontWeight.w500))),
                Text(
                  '${nd(s.fastDays.where((e) => e.startsWith('${ram.hijriYear}:')).length)} ${t('of')} ${nd(30)}',
                  style: NourText.body(14, p.muted),
                ),
              ],
            ),
            const SizedBox(height: 14),
            GridView.count(
              crossAxisCount: 10,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 6,
              children: [
                for (var d = 1; d <= 30; d++) _dayCell(p, s, ram, d),
              ],
            ),
            const SizedBox(height: 26),
            const Hairline(),
            RowLink(
              title: t('daily_wird'),
              sub: t('khatma_plan_sub').replaceAll('{n}', nd(s.khatmaDays)),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KhatmaScreen())),
            ),
            RowLink(
              title: t('zakat_fitr'),
              sub: t('zakat_fitr_sub'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ZakatScreen())),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dayCell(NourPalette p, AppState s, RamadanInfo ram, int d) {
    final key = '${ram.hijriYear}:$d';
    final done = s.fastDays.contains(key);
    final isToday = ram.inRamadan && d == ram.day;
    final canTap = ram.inRamadan && d <= ram.day;
    return Semantics(
      button: canTap,
      checked: done,
      label: '${t('day')} $d',
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: canTap
            ? () => s.update(() {
                  if (!s.fastDays.remove(key)) s.fastDays.add(key);
                })
            : null,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done ? p.accent : Colors.transparent,
            border: Border.all(color: done || isToday ? p.accent : p.muted.withOpacity(0.35)),
          ),
          child: Text(nd(d),
              style: NourText.body(11, done ? p.onAccent : (isToday ? p.accent : p.muted),
                  w: isToday ? FontWeight.w600 : FontWeight.w400)),
        ),
      ),
    );
  }
}
