import '../core/common.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';
import 'adhkar_screen.dart';
import 'home_screen.dart';
import 'prayers_screen.dart';
import 'qibla_screen.dart';
import 'quran_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _i = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final s = AppState.instance;
      await NotificationService.instance.requestPermissions();
      if (s.useGps) await LocationService.refresh();
      NotificationService.instance.scheduleSoon();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final items = [
          NavItem(Icons.home_outlined, t('nav_home')),
          NavItem(Icons.schedule, t('nav_prayers')),
          NavItem(Icons.menu_book_outlined, t('nav_quran')),
          NavItem(Icons.blur_circular, t('nav_adhkar')),
          NavItem(Icons.explore_outlined, t('nav_qibla')),
        ];
        return Scaffold(
          body: Stack(
            children: [
              IndexedStack(
                index: _i,
                children: [
                  HomeScreen(onGo: (i) => setState(() => _i = i)),
                  const PrayersScreen(),
                  const QuranScreen(),
                  const AdhkarScreen(),
                  // البوصلة لا تعمل إلا وهي ظاهرة
                  _i == 4 ? const QiblaScreen() : const SizedBox.shrink(),
                ],
              ),
              Positioned(
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).padding.bottom + 16,
                child: GlassNav(index: _i, items: items, onTap: (i) => setState(() => _i = i)),
              ),
            ],
          ),
        );
      },
    );
  }
}
