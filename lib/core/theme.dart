import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ألوان التطبيق: ورقي دافئ + حبر أخضر داكن + لون تمييز واحد.
class NourPalette extends ThemeExtension<NourPalette> {
  final bool dark;
  final Color bg, surface, ink, muted, line, accent, onAccent;

  const NourPalette({
    required this.dark,
    required this.bg,
    required this.surface,
    required this.ink,
    required this.muted,
    required this.line,
    required this.accent,
    required this.onAccent,
  });

  static const accentsLight = [Color(0xFF0E5A47), Color(0xFF1F4E79), Color(0xFF9A4A2B)];
  static const accentsDark = [Color(0xFF4FB896), Color(0xFF7DB3E8), Color(0xFFE09A76)];

  factory NourPalette.of(Brightness b, int accent) {
    final i = accent.clamp(0, 2);
    if (b == Brightness.dark) {
      return NourPalette(
        dark: true,
        bg: const Color(0xFF0C1512),
        surface: const Color(0xFF121E1A),
        ink: const Color(0xFFEDE7DA),
        muted: const Color(0xFF8FA099),
        line: const Color(0x33EDE7DA),
        accent: accentsDark[i],
        onAccent: const Color(0xFF0C1512),
      );
    }
    return NourPalette(
      dark: false,
      bg: const Color(0xFFF2EDE2),
      surface: const Color(0xFFF7F3EA),
      ink: const Color(0xFF14231F),
      muted: const Color(0xFF55635D),
      line: const Color(0x2414231F),
      accent: accentsLight[i],
      onAccent: const Color(0xFFF2EDE2),
    );
  }

  @override
  NourPalette copyWith({Color? accent}) => NourPalette(
        dark: dark,
        bg: bg,
        surface: surface,
        ink: ink,
        muted: muted,
        line: line,
        accent: accent ?? this.accent,
        onAccent: onAccent,
      );

  @override
  NourPalette lerp(ThemeExtension<NourPalette>? other, double t) =>
      other is NourPalette ? (t < 0.5 ? this : other) : this;
}

extension PaletteX on BuildContext {
  NourPalette get pal => Theme.of(this).extension<NourPalette>()!;
}

class NourText {
  static TextStyle display(double size, Color c, {FontWeight w = FontWeight.w400}) =>
      GoogleFonts.amiri(fontSize: size, color: c, fontWeight: w, height: 1.15);

  static TextStyle body(double size, Color c, {FontWeight w = FontWeight.w400, double? h}) =>
      GoogleFonts.ibmPlexSansArabic(fontSize: size, color: c, fontWeight: w, height: h);

  static TextStyle quran(double size, Color c) =>
      GoogleFonts.amiriQuran(fontSize: size, color: c, height: 2.2);
}

ThemeData buildTheme(Brightness b, int accent) {
  final p = NourPalette.of(b, accent);
  final base = ThemeData(brightness: b, useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: p.bg,
    colorScheme: ColorScheme(
      brightness: b,
      primary: p.accent,
      onPrimary: p.onAccent,
      secondary: p.accent,
      onSecondary: p.onAccent,
      error: const Color(0xFFB3261E),
      onError: Colors.white,
      surface: p.bg,
      onSurface: p.ink,
    ),
    textTheme: GoogleFonts.ibmPlexSansArabicTextTheme(base.textTheme)
        .apply(bodyColor: p.ink, displayColor: p.ink),
    extensions: [p],
    splashFactory: NoSplash.splashFactory,
    dividerColor: p.line,
  );
}
