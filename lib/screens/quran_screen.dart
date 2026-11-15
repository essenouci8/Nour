import '../core/common.dart';
import '../services/quran_api.dart';
import 'khatma_screen.dart';
import 'quran_reader.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});
  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  late Future<List<Surah>> _f = QuranApi.surahs();

  void _open(int surah, [int ayah = 1]) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => QuranReader(surah: surah, ayah: ayah)));

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final s = AppState.instance;
        return ListView(
          padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 24, 24, kNavSpace),
          children: [
            ScreenTitle(t('nav_quran'),
                trailing: IconBtn(icon: Icons.search, label: t('search'), onTap: _search)),
            const SizedBox(height: 14),
            const Hairline(),
            RowLink(
              title: t('continue_reading'),
              sub: '${t('surah')} ${nd(s.lastSurah)} · ${t('ayah')} ${nd(s.lastAyah)}',
              accentSub: true,
              onTap: () => _open(s.lastSurah, s.lastAyah),
            ),
            RowLink(
              title: t('khatma_plan'),
              sub: t('khatma_plan_sub').replaceAll('{n}', nd(s.khatmaDays)),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KhatmaScreen())),
            ),
            if (s.bookmarks.isNotEmpty)
              RowLink(
                title: t('bookmarks'),
                sub: nd(s.bookmarks.length),
                onTap: _bookmarks,
              ),
            const SizedBox(height: 8),
            FutureBuilder<List<Surah>>(
              future: _f,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: p.accent)),
                  );
                }
                if (snap.hasError || snap.data == null) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Column(
                      children: [
                        Text(t('no_connection'), style: NourText.body(14, p.muted)),
                        TextButton(
                          onPressed: () => setState(() => _f = QuranApi.surahs()),
                          child: Text(t('retry'), style: NourText.body(15, p.accent, w: FontWeight.w600)),
                        ),
                      ],
                    ),
                  );
                }
                final lang = s.lang;
                return Column(
                  children: [
                    for (final sr in snap.data!)
                      InkWell(
                        onTap: () => _open(sr.number),
                        child: Container(
                          height: 64,
                          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: p.line))),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 40,
                                child: Text(nd(sr.number), style: NourText.body(14, p.muted)),
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(lang == 'ar' ? sr.name : sr.english,
                                        style: lang == 'ar'
                                            ? NourText.display(24, p.ink)
                                            : NourText.body(16, p.ink, w: FontWeight.w500)),
                                    Text(
                                      '${sr.type == 'Meccan' ? t('meccan') : t('medinan')} · ${nd(sr.ayahs)} ${t('ayahs')}',
                                      style: NourText.body(12, p.muted),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _bookmarks() {
    final s = AppState.instance;
    final items = s.bookmarks.toList()
      ..sort((a, b) {
        final x = a.split(':').map(int.parse).toList(), y = b.split(':').map(int.parse).toList();
        return x[0] != y[0] ? x[0].compareTo(y[0]) : x[1].compareTo(y[1]);
      });
    showModalBottomSheet(
      context: context,
      backgroundColor: context.pal.bg,
      builder: (_) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final b in items)
              ListTile(
                title: Text('${t('surah')} ${nd(b.split(':')[0])} · ${t('ayah')} ${nd(b.split(':')[1])}'),
                onTap: () {
                  Navigator.pop(context);
                  _open(int.parse(b.split(':')[0]), int.parse(b.split(':')[1]));
                },
              ),
          ],
        ),
      ),
    );
  }

  void _search() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const _SearchScreen())).then((hit) {
      if (hit is SearchHit) _open(hit.surah, hit.inSurah);
    });
  }
}

class _SearchScreen extends StatefulWidget {
  const _SearchScreen();
  @override
  State<_SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<_SearchScreen> {
  Future<List<SearchHit>>? _f;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 24, 8),
              child: Row(
                children: [
                  IconBtn(icon: Icons.arrow_forward, label: t('back'), onTap: () => Navigator.pop(context)),
                  Expanded(
                    child: TextField(
                      autofocus: true,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (v) {
                        if (v.trim().length >= 2) setState(() => _f = QuranApi.search(v.trim()));
                      },
                      style: NourText.body(16, p.ink),
                      decoration: InputDecoration(
                        hintText: t('search_quran'),
                        hintStyle: NourText.body(16, p.muted),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Hairline(),
            Expanded(
              child: _f == null
                  ? const SizedBox.shrink()
                  : FutureBuilder<List<SearchHit>>(
                      future: _f,
                      builder: (context, snap) {
                        if (snap.connectionState != ConnectionState.done) {
                          return Center(child: CircularProgressIndicator(strokeWidth: 2, color: p.accent));
                        }
                        if (snap.hasError) {
                          return Center(child: Text(t('no_results'), style: NourText.body(14, p.muted)));
                        }
                        final hits = snap.data ?? [];
                        if (hits.isEmpty) {
                          return Center(child: Text(t('no_results'), style: NourText.body(14, p.muted)));
                        }
                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: hits.length,
                          itemBuilder: (_, i) => InkWell(
                            onTap: () => Navigator.pop(context, hits[i]),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: p.line))),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(hits[i].text, style: NourText.quran(22, p.ink).copyWith(height: 1.9)),
                                  const SizedBox(height: 4),
                                  Text('${hits[i].surahName} · ${t('ayah')} ${nd(hits[i].inSurah)}',
                                      style: NourText.body(12.5, p.accent)),
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
