import '../core/common.dart';
import '../services/quran_api.dart';

const _totalPages = 604;

/// ورد اليوم: صفحات خطة الختمة لليوم الحالي.
class KhatmaScreen extends StatefulWidget {
  const KhatmaScreen({super.key});
  @override
  State<KhatmaScreen> createState() => _KhatmaScreenState();
}

class _KhatmaScreenState extends State<KhatmaScreen> {
  final _ctrl = PageController();

  @override
  void initState() {
    super.initState();
    final s = AppState.instance;
    if (s.khatmaStart == null) {
      final n = DateTime.now();
      s.update(() => s.khatmaStart = DateTime(n.year, n.month, n.day));
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final s = AppState.instance;
    final n = DateTime.now();
    final start = s.khatmaStart ?? DateTime(n.year, n.month, n.day);
    final dayIndex = (DateTime.utc(n.year, n.month, n.day).difference(DateTime.utc(start.year, start.month, start.day)).inDays + 1)
        .clamp(1, s.khatmaDays).toInt();
    final perDay = (_totalPages / s.khatmaDays).ceil();
    final from = (dayIndex - 1) * perDay + 1;
    final to = (dayIndex * perDay).clamp(from, _totalPages).toInt();
    final count = to - from + 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 24, 0),
              child: Row(
                children: [
                  IconBtn(icon: Icons.arrow_forward, label: t('back'), onTap: () => Navigator.pop(context)),
                  Expanded(
                    child: Text(
                      '${t('khatma_day').replaceAll('{d}', nd(dayIndex)).replaceAll('{n}', nd(s.khatmaDays))} · ${t('pages')} ${nd(from)}–${nd(to)}',
                      style: NourText.body(13, p.muted),
                    ),
                  ),
                ],
              ),
            ),
            const Hairline(),
            Expanded(
              child: PageView.builder(
                controller: _ctrl,
                itemCount: count,
                itemBuilder: (_, i) => _PageView(page: from + i, total: count, index: i),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageView extends StatefulWidget {
  final int page, total, index;
  const _PageView({required this.page, required this.total, required this.index});
  @override
  State<_PageView> createState() => _PageViewState();
}

class _PageViewState extends State<_PageView> {
  late Future<List<Ayah>> _f = QuranApi.page(widget.page);

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final size = AppState.instance.quranSize;
    return FutureBuilder<List<Ayah>>(
      future: _f,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return Center(child: CircularProgressIndicator(strokeWidth: 2, color: p.accent));
        }
        if (snap.hasError || snap.data == null) {
          return Center(
            child: TextButton(
              onPressed: () => setState(() => _f = QuranApi.page(widget.page)),
              child: Text(t('retry'), style: NourText.body(15, p.accent, w: FontWeight.w600)),
            ),
          );
        }
        final spans = <InlineSpan>[];
        for (final a in snap.data!) {
          spans.add(TextSpan(text: '${a.text} '));
          spans.add(TextSpan(text: '﴿${nd(a.inSurah)}﴾ ', style: NourText.body(size * 0.55, p.accent)));
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          children: [
            Text.rich(
              TextSpan(children: spans),
              textAlign: TextAlign.justify,
              textDirection: TextDirection.rtl,
              style: NourText.quran(size, p.ink),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text('${nd(widget.page)} · ${nd(widget.index + 1)}/${nd(widget.total)}',
                  style: NourText.body(12.5, p.muted)),
            ),
          ],
        );
      },
    );
  }
}
