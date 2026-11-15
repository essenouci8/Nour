import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../core/app_state.dart';
import '../core/hijri.dart';
import '../core/names.dart';
import '../core/strings.dart';
import 'prayer_service.dart';

/// جدولة الأذان وتنبيهات الصيام والمناسبات والورد اليومي.
/// تُجدول الأيام القادمة عند كل فتح للتطبيق أو تغيير إعداد.
class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;
  Timer? _debounce;

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'nour_main',
      'Nour',
      channelDescription: 'Prayer times, reminders and occasions',
      importance: Importance.max,
      priority: Priority.high,
    ),
  );

  Future<void> init() async {
    try {
      tzdata.initializeTimeZones();
      await _plugin.initialize(
        const InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher')),
      );
      _ready = true;
    } catch (_) {
      _ready = false;
    }
  }

  Future<bool> requestPermissions() async {
    if (!_ready) return false;
    try {
      final a = _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      final ok = await a?.requestNotificationsPermission();
      await a?.requestExactAlarmsPermission();
      return ok ?? true;
    } catch (_) {
      return false;
    }
  }

  void scheduleSoon() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 700), reschedule);
  }

  Future<void> _at(int id, DateTime when, String title, String body) async {
    final at = tz.TZDateTime.from(when, tz.UTC);
    try {
      await _plugin.zonedSchedule(
        id, title, body, at, _details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (_) {
      // إذن المنبّهات الدقيقة غير ممنوح: نستخدم جدولة تقريبية.
      try {
        await _plugin.zonedSchedule(
          id, title, body, at, _details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        );
      } catch (_) {}
    }
  }

  Future<void> reschedule() async {
    if (!_ready) return;
    final s = AppState.instance;
    try {
      await _plugin.cancelAll();
      if (!s.hasLocation) return;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // الصلوات: 4 أيام قادمة
      var id = 1;
      for (var d = 0; d < 4; d++) {
        final day = computeDay(s.lat!, s.lon!, DateTime(today.year, today.month, today.day + d), s.method);
        for (final pid in fivePrayers) {
          final at = day[pid];
          final name = prayerName(pid);
          if (s.adhanOn && at.isAfter(now)) {
            await _at(id++, at, name, t('prayer_now').replaceAll('{p}', name));
          }
          if (s.preReminder > 0) {
            final r = at.subtract(Duration(minutes: s.preReminder));
            if (r.isAfter(now)) {
              await _at(id++, r, name,
                  t('prayer_soon').replaceAll('{p}', name).replaceAll('{m}', '${s.preReminder}'));
            }
          }
        }
      }

      // الصيام: الاثنين والخميس والأيام البيض
      if (s.fastingReminders) {
        var fid = 200;
        for (var d = 1; d <= 14; d++) {
          final day = DateTime(today.year, today.month, today.day + d);
          final h = hijriFromDate(day, adjust: s.hijriAdjust);
          final white = h.day >= 13 && h.day <= 15;
          final monThu = day.weekday == DateTime.monday || day.weekday == DateTime.thursday;
          if (!(white || monThu)) continue;
          if (h.month == 9) continue;
          if (h.month == 10 && h.day == 1) continue;
          if (h.month == 12 && h.day >= 10 && h.day <= 13) continue;
          final when = DateTime(day.year, day.month, day.day - 1, 21);
          if (when.isAfter(now)) {
            await _at(fid++, when, t('fast_title'), white ? t('fast_white') : t('fast_monthu'));
          }
        }
      }

      // المناسبات: 30 يومًا قادمة
      if (s.occasionAlerts) {
        var oid = 300;
        for (var d = 0; d <= 30; d++) {
          final day = DateTime(today.year, today.month, today.day + d);
          final h = hijriFromDate(day, adjust: s.hijriAdjust);
          for (final o in kOccasions) {
            if (o.month == h.month && o.day == h.day) {
              final when = DateTime(day.year, day.month, day.day, 9);
              if (when.isAfter(now)) await _at(oid++, when, t(o.key), t('occ_today'));
            }
          }
        }
      }

      // الورد اليومي
      if (s.khatmaReminder) {
        var kid = 400;
        for (var d = 0; d < 7; d++) {
          final when = DateTime(today.year, today.month, today.day + d, s.khatmaHour, s.khatmaMinute);
          if (when.isAfter(now)) await _at(kid++, when, t('khatma_title'), t('khatma_body'));
        }
      }
    } catch (_) {
      // الجدولة لا يجب أن توقف التطبيق.
    }
  }
}
