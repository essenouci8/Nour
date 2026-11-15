import '../core/common.dart';

/// حاسبة زكاة المال وزكاة الفطر. الأسعار يدخلها المستخدم ولا يفترضها التطبيق.
class ZakatScreen extends StatefulWidget {
  const ZakatScreen({super.key});
  @override
  State<ZakatScreen> createState() => _ZakatScreenState();
}

class _ZakatScreenState extends State<ZakatScreen> {
  final _gold = TextEditingController();
  final _cash = TextEditingController();
  final _goldG = TextEditingController();
  final _trade = TextEditingController();
  final _debts = TextEditingController();
  final _people = TextEditingController();
  final _perPerson = TextEditingController();

  @override
  void initState() {
    super.initState();
    final g = AppState.instance.goldPrice;
    if (g > 0) _gold.text = g.toString();
  }

  @override
  void dispose() {
    for (final c in [_gold, _cash, _goldG, _trade, _debts, _people, _perPerson]) {
      c.dispose();
    }
    super.dispose();
  }

  double _v(TextEditingController c) => parseNum(c.text) ?? 0;

  String _fmt(double v) => nd(v.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), ''));

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final price = _v(_gold);
    final total = _v(_cash) + _v(_goldG) * price + _v(_trade);
    final net = total - _v(_debts);
    final nisab = 85 * price;
    final due = price > 0 && net >= nisab && net > 0;
    final zakat = due ? net * 0.025 : 0.0;
    final fitr = _v(_people) * _v(_perPerson);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 40),
          children: [
            Row(
              children: [
                IconBtn(icon: Icons.arrow_forward, label: t('back'), onTap: () => Navigator.pop(context)),
                Expanded(child: Text(t('zakat'), style: NourText.display(30, p.ink))),
              ],
            ),
            SectionLabel(t('zakat_mal')),
            _field(p, _gold, t('gold_price'), onChanged: (v) {
              final s = AppState.instance;
              s.update(() => s.goldPrice = parseNum(v) ?? 0);
            }),
            _field(p, _cash, t('cash_savings')),
            _field(p, _goldG, t('gold_grams')),
            _field(p, _trade, t('trade_goods')),
            _field(p, _debts, t('debts_due')),
            const SizedBox(height: 18),
            const Hairline(),
            _result(p, t('nisab'), price > 0 ? _fmt(nisab) : '—'),
            _result(p, t('net_wealth'), _fmt(net)),
            _result(p, t('zakat_due'), due ? _fmt(zakat) : (price > 0 ? t('no_zakat') : '—'), strong: due),
            const SizedBox(height: 10),
            Text(t('zakat_note'), style: NourText.body(12.5, p.muted, h: 1.7)),
            SectionLabel(t('zakat_fitr')),
            _field(p, _people, t('people_count')),
            _field(p, _perPerson, t('fitr_per_person')),
            const Hairline(),
            _result(p, t('fitr_total'), fitr > 0 ? _fmt(fitr) : '—', strong: fitr > 0),
            const SizedBox(height: 10),
            Text(t('zakat_ask'), style: NourText.body(12.5, p.muted, h: 1.7)),
          ],
        ),
      ),
    );
  }

  Widget _field(NourPalette p, TextEditingController c, String label, {ValueChanged<String>? onChanged}) {
    return Container(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: p.line))),
      child: TextField(
        controller: c,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: (v) {
          onChanged?.call(v);
          setState(() {});
        },
        style: NourText.body(17, p.ink),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: NourText.body(14, p.muted),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _result(NourPalette p, String k, String v, {bool strong = false}) => Container(
        height: 56,
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: p.line))),
        child: Row(
          children: [
            Expanded(child: Text(k, style: NourText.body(15, p.muted))),
            Text(v,
                style: NourText.body(strong ? 22 : 17, strong ? p.accent : p.ink,
                    w: strong ? FontWeight.w600 : FontWeight.w500)),
          ],
        ),
      );
}
