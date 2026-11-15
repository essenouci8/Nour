import 'dart:async';
import 'dart:ui' show FontFeature;

import '../core/common.dart';
import '../core/geo.dart';
import '../core/hijri.dart';
import '../data/cities.dart';
import '../services/prayer_service.dart';
import 'calendar_screen.dart';
import 'city_picker.dart';
import 'quran_reader.dart';
import 'ramadan_screen.dart';
import 'settings_screen.dart';
import 'zakat_screen.dart';

class HomeScreen extends StatefulWidget {
  final ValueChanged<int> onGo;
  const HomeScreen({super.key, required this.onGo});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

  void _push(Widget w) => Navigator.push(context, MaterialPageRoute(builder: (_) => w));

  Future<void> _pickCity() async {
    final id = await Navigator.push<int>(context, MaterialPageRoute(builder: (_) => const CityPickerScreen()));
    if (id == null) return;
    final c = kCities[id];
    AppState.instance.setLocation(c.lat, c.lon, city: id, gps: false);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(listenable: AppState.instance, builder: (context, _) => _body(context));
  }

  Widget _body(BuildContext context) {
    final s = AppState.instance;
    final p = context.pal;
    if (!s.hasLocation) return const SizedBox.shrink();

    final now = DateTime.now();
    final info = nextPrayer(s.lat!, s.lon!, s.method, now);
    final today = computeDay(s.lat!, s.lon!, now, s.method);
    final left = info.at.difference(now);
    final span = info.at.difference(info.prev).inSeconds;
    final prog = span <= 0 ? 0.0 : (now.difference(info.prev).inSeconds / span).clamp(0.0, 1.0).toDouble();
    final hij = hijriFromDate(now, adjust: s.hijriAdjust);
    final ram = ramadanInfo(now, s.hijriAdjust);

    double bar(int i) {
      final tm = today[fivePrayers[i]];
      if (tm.isBefore(now)) return 1;
      if (fivePrayers[i] == info.id && info.at == tm) return prog;
      return 0;
    }

    return ListView(
      padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 24, 24, kNavSpace),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(gregorianLabel(now), style: NourText.body(15, p.ink, w: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(hijriLabel(hij), style: NourText.body(13, p.muted)),
                ],
              ),
            ),
            InkWell(
              onTap: _pickCity,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 44),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.place_outlined, size: 16, color: p.muted),
                    const SizedBox(width: 4),
                    Text(cityLabel(s, t('my_location')), style: NourText.body(13, p.muted)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 36),
        Row(
          children: [
            Container(width: 6, height: 6, decoration: BoxDecoration(color: p.accent, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(t('next_prayer'), style: NourText.body(13, p.muted)),
          ],
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          child: Text(prayerName(info.id), style: NourText.display(92, p.ink)),
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(fmtTime(info.at),
                style: NourText.body(40, p.ink, w: FontWeight.w300).copyWith(fontFeatures: const [FontFeature.tabularFigures()])),
            Container(width: 1, height: 24, margin: const EdgeInsets.symmetric(horizontal: 16), color: p.line),
            Text(t('after'), style: NourText.body(14, p.muted)),
            const SizedBox(width: 6),
            Text(fmtDuration(left),
                style: NourText.body(18, p.accent, w: FontWeight.w500).copyWith(fontFeatures: const [FontFeature.tabularFigures()])),
          ],
        ),
        const SizedBox(height: 40),
        Row(
          children: [
            for (var i = 0; i < 5; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: Stack(
                        children: [
                          Container(height: 3, color: p.line),
                          FractionallySizedBox(
                            widthFactor: bar(i).clamp(0.0, 1.0).toDouble(),
                            child: Container(
                              height: 3,
                              color: fivePrayers[i] == info.id ? p.accent : p.ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(prayerName(fivePrayers[i]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: NourText.body(13, fivePrayers[i] == info.id ? p.accent : p.ink,
                            w: fivePrayers[i] == info.id ? FontWeight.w600 : FontWeight.w500)),
                    const SizedBox(height: 2),
                    Text(fmtTime(today[fivePrayers[i]]),
                        style: NourText.body(15, today[fivePrayers[i]].isBefore(now) ? p.muted : p.ink)),
                  ],
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 32),
        const Hairline(),
        RowLink(
          title: t('nav_quran'),
          sub: '${t('last_read')}: ${t('surah')} ${nd(s.lastSurah)} · ${t('ayah')} ${nd(s.lastAyah)}',
          onTap: () => _push(QuranReader(surah: s.lastSurah, ayah: s.lastAyah)),
        ),
        RowLink(title: t('nav_adhkar'), sub: t('home_adhkar_sub'), onTap: () => widget.onGo(3)),
        RowLink(
          title: t('nav_qibla'),
          sub: '${nd(qiblaDeg(s))}° ${t('from_north')}',
          onTap: () => widget.onGo(4),
        ),
        RowLink(
          title: t('ramadan'),
          sub: ram.inRamadan ? t('ramadan_day').replaceAll('{n}', nd(ram.day)) : t('ramadan_in').replaceAll('{n}', nd(ram.daysTo)),
          accentSub: true,
          onTap: () => _push(const RamadanScreen()),
        ),
        RowLink(title: t('calendar'), sub: t('calendar_sub'), onTap: () => _push(const CalendarScreen())),
        RowLink(title: t('zakat'), sub: t('zakat_sub'), onTap: () => _push(const ZakatScreen())),
        RowLink(title: t('settings'), onTap: () => _push(const SettingsScreen())),
      ],
    );
  }
}

int qiblaDeg(AppState s) => qiblaBearing(s.lat!, s.lon!).round();
