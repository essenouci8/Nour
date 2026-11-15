import 'dart:ui' show FontFeature;

import '../core/common.dart';
import '../core/hijri.dart';
import '../data/cities.dart';
import '../services/prayer_service.dart';

class PrayersScreen extends StatefulWidget {
  const PrayersScreen({super.key});
  @override
  State<PrayersScreen> createState() => _PrayersScreenState();
}

class _PrayersScreenState extends State<PrayersScreen> {
  int _off = 0;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(listenable: AppState.instance, builder: (context, _) => _body(context));
  }

  Widget _body(BuildContext context) {
    final s = AppState.instance;
    final p = context.pal;
    if (!s.hasLocation) return const SizedBox.shrink();
    final now = DateTime.now();
    final date = DateTime(now.year, now.month, now.day + _off);
    final day = computeDay(s.lat!, s.lon!, date, s.method);
    final next = _off == 0 ? nextPrayer(s.lat!, s.lon!, s.method, now).id : null;
    final hij = hijriFromDate(date, adjust: s.hijriAdjust);
    final done = [for (final id in fivePrayers) if (s.isDone(date, id.index)) id].length;

    return ListView(
      padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 24, 24, kNavSpace),
      children: [
        ScreenTitle(t('nav_prayers'),
            trailing: Text(cityLabel(s, t('my_location')), style: NourText.body(13, p.muted))),
        const SizedBox(height: 10),
        Row(
          children: [
            IconBtn(icon: Icons.chevron_right, label: t('prev_day'), onTap: () => setState(() => _off--)),
            Expanded(
              child: Column(
                children: [
                  Text(gregorianLabel(date), style: NourText.body(15, p.ink, w: FontWeight.w500)),
                  Text(hijriLabel(hij), style: NourText.body(12.5, p.muted)),
                ],
              ),
            ),
            IconBtn(icon: Icons.chevron_left, label: t('next_day'), onTap: () => setState(() => _off++)),
          ],
        ),
        const SizedBox(height: 14),
        const Hairline(),
        for (final id in PrayerId.values) _row(context, id, day[id], next == id, date, s),
        const SizedBox(height: 22),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(
              child: Text(t('done_count').replaceAll('{n}', nd(done)), style: NourText.body(14, p.muted)),
            ),
            Text(nd('${done * 20}%'), style: NourText.body(14, p.accent, w: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: Stack(
            children: [
              Container(height: 3, color: p.line),
              FractionallySizedBox(
                widthFactor: done / 5,
                child: AnimatedContainer(duration: const Duration(milliseconds: 400), height: 3, color: p.accent),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _row(BuildContext context, PrayerId id, DateTime time, bool isNext, DateTime date, AppState s) {
    final p = context.pal;
    final isSun = id == PrayerId.sunrise;
    final on = !isSun && s.isDone(date, id.index);
    final canMark = !isSun && _off <= 0;
    final color = isSun ? p.muted : (isNext ? p.accent : p.ink);
    return Container(
      height: 62,
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: p.line))),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(prayerName(id),
                    style: NourText.body(isNext ? 22 : 17, color, w: isNext ? FontWeight.w600 : FontWeight.w400)),
                if (isNext) Text(t('next_prayer'), style: NourText.body(12, p.accent)),
              ],
            ),
          ),
          Text(fmtTime(time),
              style: NourText.body(18, color, w: isNext ? FontWeight.w600 : FontWeight.w400)
                  .copyWith(fontFeatures: const [FontFeature.tabularFigures()])),
          SizedBox(
            width: 44,
            height: 44,
            child: canMark
                ? Semantics(
                    button: true,
                    checked: on,
                    label: '${t('mark_prayed')} ${prayerName(id)}',
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => s.toggleDone(date, id.index),
                      child: Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: on ? p.accent : Colors.transparent,
                            border: Border.all(color: on ? p.accent : p.muted.withOpacity(0.6), width: 1.5),
                          ),
                          child: on ? Icon(Icons.check, size: 15, color: p.onAccent) : null,
                        ),
                      ),
                    ),
                  )
                : null,
          ),
        ],
      ),
    );
  }
}
