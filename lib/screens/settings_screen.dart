import '../core/common.dart';
import '../data/cities.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';
import '../services/prayer_service.dart';
import '../services/quran_api.dart';
import 'city_picker.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: AppState.instance,
          builder: (context, _) {
            final s = AppState.instance;
            return ListView(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 40),
              children: [
                Row(
                  children: [
                    IconBtn(icon: Icons.arrow_forward, label: t('back'), onTap: () => Navigator.pop(context)),
                    Expanded(child: Text(t('settings'), style: NourText.display(30, p.ink))),
                  ],
                ),

                SectionLabel(t('set_general')),
                _row(context, t('language'), _langName(s.lang), () => _choose<String>(context, t('language'),
                    const {'ar': 'العربية', 'en': 'English', 'fr': 'Français'}, s.lang, (v) => s.update(() => s.lang = v, resched: true))),
                _row(context, t('appearance'), _themeName(s.themeMode), () => _choose<ThemeMode>(context, t('appearance'), {
                      ThemeMode.light: t('theme_light'),
                      ThemeMode.dark: t('theme_dark'),
                      ThemeMode.system: t('theme_system'),
                    }, s.themeMode, (v) => s.update(() => s.themeMode = v))),
                _accentRow(context, s),

                SectionLabel(t('set_prayer')),
                _row(context, t('location'), cityLabel(s, t('my_location')), () => _location(context)),
                _row(context, t('calc_method'), t('m_${s.method}'), () => _choose<String>(context, t('calc_method'),
                    {for (final m in kMethods) m: t('m_$m')}, s.method, (v) => s.update(() => s.method = v, resched: true))),
                _row(context, t('hijri_adjust'), s.hijriAdjust == 0 ? t('none') : (s.hijriAdjust > 0 ? '+${nd(s.hijriAdjust)}' : nd(s.hijriAdjust)),
                    () => _choose<int>(context, t('hijri_adjust'),
                        {for (final d in [-2, -1, 0, 1, 2]) d: d == 0 ? t('none') : (d > 0 ? '+${nd(d)}' : nd(d))},
                        s.hijriAdjust, (v) => s.update(() => s.hijriAdjust = v, resched: true))),

                SectionLabel(t('set_alerts')),
                _switch(context, t('adhan_alert'), s.adhanOn, (v) async {
                  if (v) await NotificationService.instance.requestPermissions();
                  s.update(() => s.adhanOn = v, resched: true);
                }),
                _row(context, t('pre_reminder'), s.preReminder == 0 ? t('off') : '${nd(s.preReminder)} ${t('minute')}',
                    () => _choose<int>(context, t('pre_reminder'),
                        {for (final m in [0, 5, 10, 15, 20]) m: m == 0 ? t('off') : '${nd(m)} ${t('minute')}'},
                        s.preReminder, (v) => s.update(() => s.preReminder = v, resched: true))),
                _switch(context, t('fasting_reminders'), s.fastingReminders, (v) async {
                  if (v) await NotificationService.instance.requestPermissions();
                  s.update(() => s.fastingReminders = v, resched: true);
                }),
                _switch(context, t('occasion_alerts'), s.occasionAlerts,
                    (v) => s.update(() => s.occasionAlerts = v, resched: true)),

                SectionLabel(t('set_quran')),
                _row(context, t('font_size'), nd(s.quranSize.round()), () => _fontSheet(context)),
                _row(context, t('reciter'), _reciter(s), () => _choose<String>(context, t('reciter'),
                    {for (final r in kReciters) r.id: s.lang == 'ar' ? r.ar : r.en}, s.reciter, (v) => s.update(() => s.reciter = v))),
                _row(context, t('khatma_days'), nd(s.khatmaDays), () => _choose<int>(context, t('khatma_days'),
                    {for (final d in [15, 30, 60, 90]) d: nd(d)}, s.khatmaDays, (v) => s.update(() {
                          s.khatmaDays = v;
                          final n = DateTime.now();
                          s.khatmaStart = DateTime(n.year, n.month, n.day);
                        }))),
                _switch(context, t('khatma_reminder'), s.khatmaReminder, (v) async {
                  if (v) await NotificationService.instance.requestPermissions();
                  s.update(() => s.khatmaReminder = v, resched: true);
                }),
                if (s.khatmaReminder)
                  _row(context, t('reminder_time'), '${pad2(s.khatmaHour)}:${pad2(s.khatmaMinute)}', () async {
                    final r = await showTimePicker(
                        context: context, initialTime: TimeOfDay(hour: s.khatmaHour, minute: s.khatmaMinute));
                    if (r != null) {
                      s.update(() {
                        s.khatmaHour = r.hour;
                        s.khatmaMinute = r.minute;
                      }, resched: true);
                    }
                  }),

                const SizedBox(height: 44),
                Center(child: StarMark(size: 56, color: p.accent, hole: p.bg)),
                const SizedBox(height: 14),
                Center(child: Text('نور', style: NourText.display(34, p.ink))),
                const SizedBox(height: 4),
                Center(child: Text('${t('version')} 1.0.0', style: NourText.body(12.5, p.muted))),
                const SizedBox(height: 14),
                // اسم المطوّر يظهر هنا فقط
                Center(
                  child: Text(t('developed_by'),
                      textAlign: TextAlign.center, style: NourText.body(14, p.ink, w: FontWeight.w500)),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  static String _langName(String l) => const {'ar': 'العربية', 'en': 'English', 'fr': 'Français'}[l]!;

  static String _themeName(ThemeMode m) =>
      m == ThemeMode.light ? t('theme_light') : (m == ThemeMode.dark ? t('theme_dark') : t('theme_system'));

  static String _reciter(AppState s) {
    final r = kReciters.firstWhere((r) => r.id == s.reciter, orElse: () => kReciters.first);
    return s.lang == 'ar' ? r.ar : r.en;
  }

  Widget _row(BuildContext context, String title, String value, VoidCallback onTap) {
    final p = context.pal;
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: p.line))),
        child: Row(
          children: [
            Expanded(child: Text(title, style: NourText.body(16, p.ink))),
            Flexible(child: Text(value, style: NourText.body(14, p.muted), textAlign: TextAlign.end)),
            const SizedBox(width: 6),
            Icon(chevronIcon(context), size: 18, color: p.muted),
          ],
        ),
      ),
    );
  }

  Widget _switch(BuildContext context, String title, bool value, ValueChanged<bool> onChanged) {
    final p = context.pal;
    return Container(
      constraints: const BoxConstraints(minHeight: 56),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: p.line))),
      child: Row(
        children: [
          Expanded(child: Text(title, style: NourText.body(16, p.ink))),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _accentRow(BuildContext context, AppState s) {
    final p = context.pal;
    final list = p.dark ? NourPalette.accentsDark : NourPalette.accentsLight;
    return Container(
      constraints: const BoxConstraints(minHeight: 56),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: p.line))),
      child: Row(
        children: [
          Expanded(child: Text(t('accent_color'), style: NourText.body(16, p.ink))),
          for (var i = 0; i < list.length; i++)
            InkWell(
              customBorder: const CircleBorder(),
              onTap: () => s.update(() => s.accent = i),
              child: Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: list[i],
                    shape: BoxShape.circle,
                    border: Border.all(color: s.accent == i ? p.ink : Colors.transparent, width: 2),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _choose<T>(BuildContext context, String title, Map<T, String> options, T current, void Function(T) onPick) {
    final p = context.pal;
    return showModalBottomSheet(
      context: context,
      backgroundColor: p.bg,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 6),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(title, style: NourText.body(13, p.accent, w: FontWeight.w600)),
              ),
            ),
            for (final e in options.entries)
              ListTile(
                title: Text(e.value, style: NourText.body(16, p.ink)),
                trailing: e.key == current ? Icon(Icons.check, color: p.accent) : null,
                onTap: () {
                  onPick(e.key);
                  Navigator.pop(ctx);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _location(BuildContext context) {
    final p = context.pal;
    showModalBottomSheet(
      context: context,
      backgroundColor: p.bg,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.my_location, color: p.accent),
              title: Text(t('use_gps'), style: NourText.body(16, p.ink)),
              onTap: () async {
                Navigator.pop(ctx);
                final ok = await LocationService.refresh();
                if (!ok && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('loc_denied'))));
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.place_outlined, color: p.accent),
              title: Text(t('choose_city'), style: NourText.body(16, p.ink)),
              onTap: () async {
                Navigator.pop(ctx);
                final id = await Navigator.push<int>(
                    context, MaterialPageRoute(builder: (_) => const CityPickerScreen()));
                if (id != null) {
                  final c = kCities[id];
                  AppState.instance.setLocation(c.lat, c.lon, city: id, gps: false);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _fontSheet(BuildContext context) {
    final p = context.pal;
    showModalBottomSheet(
      context: context,
      backgroundColor: p.bg,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) {
          final s = AppState.instance;
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ', style: NourText.quran(s.quranSize, p.ink)),
                  Slider(
                    min: 22,
                    max: 40,
                    divisions: 9,
                    value: s.quranSize.clamp(22.0, 40.0).toDouble(),
                    onChanged: (v) {
                      s.update(() => s.quranSize = v);
                      setSheet(() {});
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
