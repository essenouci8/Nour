import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/app_state.dart';
import 'core/theme.dart';
import 'screens/app_shell.dart';
import 'screens/welcome_screen.dart';

class NourApp extends StatelessWidget {
  const NourApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final s = AppState.instance;
        return MaterialApp(
          title: 'نور',
          debugShowCheckedModeBanner: false,
          locale: Locale(s.lang),
          supportedLocales: const [Locale('ar'), Locale('en'), Locale('fr')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          themeMode: s.themeMode,
          theme: buildTheme(Brightness.light, s.accent),
          darkTheme: buildTheme(Brightness.dark, s.accent),
          home: const _Root(),
        );
      },
    );
  }
}

class _Root extends StatelessWidget {
  const _Root();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) =>
          AppState.instance.onboarded && AppState.instance.hasLocation
              ? const AppShell()
              : const WelcomeScreen(),
    );
  }
}
