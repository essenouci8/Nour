import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/notification_service.dart';

/// حالة التطبيق وإعداداته، تُحفظ كلها في SharedPreferences.
class AppState extends ChangeNotifier {
  static final AppState instance = AppState._();
  AppState._();

  late SharedPreferences _p;

  // عام
  String lang = 'ar';
  ThemeMode themeMode = ThemeMode.light;
  int accent = 0;
  bool onboarded = false;

  // الموقع والمواقيت
  double? lat;
  double? lon;
  int cityId = -1; // فهرس في kCities، أو -1 = موقعي الحالي
  bool useGps = true;
  String method = 'algeria';
  int hijriAdjust = 0;

  // التنبيهات
  bool adhanOn = true;
  int preReminder = 10;
  bool fastingReminders = false;
  bool occasionAlerts = true;

  // القرآن
  double quranSize = 28;
  String reciter = 'ar.alafasy';
  int lastSurah = 1;
  int lastAyah = 1;
  Set<String> bookmarks = {};
  int khatmaDays = 30;
  DateTime? khatmaStart;
  bool khatmaReminder = false;
  int khatmaHour = 20;
  int khatmaMinute = 0;

  // العبادة
  Set<String> prayerDone = {};
  Map<String, int> tasbihDaily = {};
  Set<String> fastDays = {};
  double goldPrice = 0;

  bool get hasLocation => lat != null && lon != null;

  static String dayKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> load() async {
    _p = await SharedPreferences.getInstance();
    final dev = ui.PlatformDispatcher.instance.locale.languageCode;
    lang = _p.getString('lang') ?? (const ['ar', 'en', 'fr'].contains(dev) ? dev : 'ar');
    themeMode = ThemeMode.values[(_p.getInt('theme') ?? 1).clamp(0, 2)];
    accent = _p.getInt('accent') ?? 0;
    onboarded = _p.getBool('onboarded') ?? false;
    lat = _p.getDouble('lat');
    lon = _p.getDouble('lon');
    cityId = _p.getInt('cityId') ?? -1;
    useGps = _p.getBool('useGps') ?? true;
    method = _p.getString('method') ?? 'algeria';
    hijriAdjust = _p.getInt('hijriAdjust') ?? 0;
    adhanOn = _p.getBool('adhanOn') ?? true;
    preReminder = _p.getInt('preReminder') ?? 10;
    fastingReminders = _p.getBool('fastingReminders') ?? false;
    occasionAlerts = _p.getBool('occasionAlerts') ?? true;
    quranSize = _p.getDouble('quranSize') ?? 28;
    reciter = _p.getString('reciter') ?? 'ar.alafasy';
    lastSurah = _p.getInt('lastSurah') ?? 1;
    lastAyah = _p.getInt('lastAyah') ?? 1;
    bookmarks = (_p.getStringList('bookmarks') ?? []).toSet();
    khatmaDays = _p.getInt('khatmaDays') ?? 30;
    final ks = _p.getString('khatmaStart');
    khatmaStart = ks == null ? null : DateTime.tryParse(ks);
    khatmaReminder = _p.getBool('khatmaReminder') ?? false;
    khatmaHour = _p.getInt('khatmaHour') ?? 20;
    khatmaMinute = _p.getInt('khatmaMinute') ?? 0;
    prayerDone = (_p.getStringList('prayerDone') ?? []).toSet();
    fastDays = (_p.getStringList('fastDays') ?? []).toSet();
    goldPrice = _p.getDouble('goldPrice') ?? 0;
    tasbihDaily = {
      for (final e in (_p.getStringList('tasbih') ?? []))
        if (e.contains('=')) e.split('=')[0]: int.tryParse(e.split('=')[1]) ?? 0,
    };
  }

  Future<void> _save() async {
    await _p.setString('lang', lang);
    await _p.setInt('theme', themeMode.index);
    await _p.setInt('accent', accent);
    await _p.setBool('onboarded', onboarded);
    if (lat != null) await _p.setDouble('lat', lat!);
    if (lon != null) await _p.setDouble('lon', lon!);
    await _p.setInt('cityId', cityId);
    await _p.setBool('useGps', useGps);
    await _p.setString('method', method);
    await _p.setInt('hijriAdjust', hijriAdjust);
    await _p.setBool('adhanOn', adhanOn);
    await _p.setInt('preReminder', preReminder);
    await _p.setBool('fastingReminders', fastingReminders);
    await _p.setBool('occasionAlerts', occasionAlerts);
    await _p.setDouble('quranSize', quranSize);
    await _p.setString('reciter', reciter);
    await _p.setInt('lastSurah', lastSurah);
    await _p.setInt('lastAyah', lastAyah);
    await _p.setStringList('bookmarks', bookmarks.toList());
    await _p.setInt('khatmaDays', khatmaDays);
    if (khatmaStart != null) await _p.setString('khatmaStart', khatmaStart!.toIso8601String());
    await _p.setBool('khatmaReminder', khatmaReminder);
    await _p.setInt('khatmaHour', khatmaHour);
    await _p.setInt('khatmaMinute', khatmaMinute);
    await _p.setStringList('prayerDone', prayerDone.toList());
    await _p.setStringList('fastDays', fastDays.toList());
    await _p.setDouble('goldPrice', goldPrice);
    await _p.setStringList('tasbih', [for (final e in tasbihDaily.entries) '${e.key}=${e.value}']);
  }

  /// يعدّل الحالة ويحفظها ويُعلم المستمعين. `resched` يعيد جدولة التنبيهات.
  void update(VoidCallback f, {bool resched = false}) {
    f();
    notifyListeners();
    _save();
    if (resched) NotificationService.instance.scheduleSoon();
  }

  void setLocation(double la, double lo, {int city = -1, bool gps = false}) {
    update(() {
      lat = la;
      lon = lo;
      cityId = city;
      useGps = gps;
    }, resched: true);
  }

  bool isDone(DateTime d, int i) => prayerDone.contains('${dayKey(d)}:$i');

  void toggleDone(DateTime d, int i) => update(() {
        final k = '${dayKey(d)}:$i';
        if (!prayerDone.remove(k)) prayerDone.add(k);
      });

  int get tasbihToday => tasbihDaily[dayKey(DateTime.now())] ?? 0;

  /// بدون notifyListeners حتى لا تُعاد بناء الواجهة كلها مع كل تسبيحة.
  void addTasbih() {
    final k = dayKey(DateTime.now());
    tasbihDaily[k] = (tasbihDaily[k] ?? 0) + 1;
    _save();
  }

  bool get quranBookmarked => bookmarks.contains('$lastSurah:$lastAyah');
}
