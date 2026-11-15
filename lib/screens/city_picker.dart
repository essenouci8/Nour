import '../core/common.dart';
import '../data/cities.dart';

/// يرجع فهرس المدينة المختارة في kCities.
class CityPickerScreen extends StatefulWidget {
  const CityPickerScreen({super.key});
  @override
  State<CityPickerScreen> createState() => _CityPickerScreenState();
}

class _CityPickerScreenState extends State<CityPickerScreen> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final lang = AppState.instance.lang;
    final q = _q.trim().toLowerCase();
    final ids = [
      for (var i = 0; i < kCities.length; i++)
        if (q.isEmpty || kCities[i].ar.contains(q) || kCities[i].en.toLowerCase().contains(q)) i
    ];
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
                      onChanged: (v) => setState(() => _q = v),
                      style: NourText.body(16, p.ink),
                      decoration: InputDecoration(
                        hintText: t('search_city'),
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
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: ids.length,
                itemBuilder: (_, k) {
                  final c = kCities[ids[k]];
                  return InkWell(
                    onTap: () => Navigator.pop(context, ids[k]),
                    child: Container(
                      height: 56,
                      alignment: AlignmentDirectional.centerStart,
                      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: p.line))),
                      child: Text(c.name(lang), style: NourText.body(17, p.ink)),
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
