import 'dart:math' as math;

import '../core/common.dart';
import '../data/cities.dart';
import '../services/location_service.dart';
import 'city_picker.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});
  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _spin =
      AnimationController(vsync: this, duration: const Duration(seconds: 120))..repeat();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  Future<void> _allow() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final pos = await LocationService.current();
    if (!mounted) return;
    if (pos == null) {
      setState(() {
        _busy = false;
        _error = t('loc_denied');
      });
      return;
    }
    final s = AppState.instance;
    s.setLocation(pos.lat, pos.lon, city: nearestCityId(pos.lat, pos.lon), gps: true);
    s.update(() => s.onboarded = true);
  }

  Future<void> _pick() async {
    final id = await Navigator.push<int>(context, MaterialPageRoute(builder: (_) => const CityPickerScreen()));
    if (id == null) return;
    final c = kCities[id];
    final s = AppState.instance;
    s.setLocation(c.lat, c.lon, city: id, gps: false);
    s.update(() => s.onboarded = true);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          child: Column(
            children: [
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton(
                  onPressed: _busy ? null : _langSheet,
                  child: Text(const {'ar': 'العربية', 'en': 'English', 'fr': 'Français'}[AppState.instance.lang]!,
                      style: NourText.body(14, p.muted)),
                ),
              ),
              const Spacer(flex: 2),
              SizedBox(
                width: 260,
                height: 260,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _spin,
                      builder: (_, __) => Transform.rotate(
                        angle: _spin.value * 2 * math.pi,
                        child: StarOutline(size: 260, color: p.accent.withOpacity(0.4)),
                      ),
                    ),
                    Text('نور', style: NourText.display(96, p.ink)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(t('welcome_sub'),
                  textAlign: TextAlign.center, style: NourText.body(16, p.muted, h: 1.9)),
              const Spacer(flex: 3),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(_error!, textAlign: TextAlign.center, style: NourText.body(13, const Color(0xFFB3261E))),
                ),
              Text(t('privacy_note'), textAlign: TextAlign.center, style: NourText.body(12.5, p.muted, h: 1.7)),
              const SizedBox(height: 16),
              AccentButton(label: _busy ? t('loading') : t('allow_location'), onTap: _busy ? null : _allow),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _busy ? null : _pick,
                style: TextButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
                child: Text(t('choose_city'), style: NourText.body(15, p.ink, w: FontWeight.w500)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _langSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.pal.bg,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final e in const {'ar': 'العربية', 'en': 'English', 'fr': 'Français'}.entries)
              ListTile(
                title: Text(e.value),
                trailing: AppState.instance.lang == e.key ? Icon(Icons.check, color: context.pal.accent) : null,
                onTap: () {
                  AppState.instance.update(() => AppState.instance.lang = e.key);
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }
}
