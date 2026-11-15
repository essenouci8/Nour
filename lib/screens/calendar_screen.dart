import '../core/common.dart';
import '../core/hijri.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});
  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  int? _y;
  int? _m;

  @override
  Widget build(BuildContext context) {
    final s = AppState.instance;
    final p = context.pal;
    final adj = s.hijriAdjust;
    final now = DateTime.now();
    final today = hijriFromDate(now, adjust: adj);
    final y = _y ?? today.year;
    final m = _m ?? today.month;

    final first = hijriToGregorian(y, m, 1, adjust: adj);
    final len = hijriMonthLength(y, m, adjust: adj);
    final offset = first.weekday % 7; // الأحد = 0
    final initials = weekdayInitialsSunFirst();

    void shift(int d) {
      var nm = m + d, ny = y;
      if (nm > 12) {
        nm = 1;
        ny++;
      } else if (nm < 1) {
        nm = 12;
        ny--;
      }
      setState(() {
        _y = ny;
        _m = nm;
      });
    }

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 32),
          children: [
            Row(
              children: [
                IconBtn(icon: Icons.arrow_forward, label: t('back'), onTap: () => Navigator.pop(context)),
                Expanded(child: Text(t('calendar'), style: NourText.display(30, p.ink))),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                IconBtn(icon: Icons.chevron_right, label: t('prev_month'), onTap: () => shift(-1)),
                Expanded(
                  child: Center(
                    child: Text('${hMonthName(m)} ${nd(y)}', style: NourText.display(30, p.ink)),
                  ),
                ),
                IconBtn(icon: Icons.chevron_left, label: t('next_month'), onTap: () => shift(1)),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                for (final d in initials)
                  Expanded(child: Center(child: Text(d, style: NourText.body(12.5, p.muted, w: FontWeight.w500)))),
              ],
            ),
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount: 7,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 0.82,
              children: [
                for (var i = 0; i < offset; i++) const SizedBox.shrink(),
                for (var d = 1; d <= len; d++) _cell(p, y, m, d, today, first),
              ],
            ),
            SectionLabel(t('occasions')),
            for (final o in kOccasions)
              Container(
                height: 60,
                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: p.line))),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t(o.key), style: NourText.body(16, p.ink, w: FontWeight.w500)),
                          Text('${nd(o.day)} ${hMonthName(o.month)}', style: NourText.body(12.5, p.muted)),
                        ],
                      ),
                    ),
                    Text(fullGregorian(hijriToGregorian(y, o.month, o.day, adjust: adj)),
                        style: NourText.body(13, p.accent)),
                  ],
                ),
              ),
            const SizedBox(height: 14),
            Text(t('hijri_note'), style: NourText.body(12.5, p.muted, h: 1.7)),
          ],
        ),
      ),
    );
  }

  Widget _cell(NourPalette p, int y, int m, int d, HijriDate today, DateTime first) {
    final g = DateTime(first.year, first.month, first.day + d - 1);
    final isToday = today.year == y && today.month == m && today.day == d;
    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isToday ? p.accent : Colors.transparent,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(nd(d), style: NourText.body(16, isToday ? p.onAccent : p.ink, w: FontWeight.w500)),
          Text('${g.day}',
              style: NourText.body(10, isToday ? p.onAccent.withOpacity(0.8) : p.muted)),
        ],
      ),
    );
  }
}
