import 'package:adhan/adhan.dart';

enum PrayerId { fajr, sunrise, dhuhr, asr, maghrib, isha }

const fivePrayers = [PrayerId.fajr, PrayerId.dhuhr, PrayerId.asr, PrayerId.maghrib, PrayerId.isha];

/// طرق الحساب المتاحة (المفتاح يُحفظ في الإعدادات).
const kMethods = ['algeria', 'mwl', 'egypt', 'umm', 'karachi'];

CalculationParameters paramsFor(String method) {
  switch (method) {
    case 'mwl':
      return CalculationMethod.muslim_world_league.getParameters();
    case 'egypt':
      return CalculationMethod.egyptian.getParameters();
    case 'umm':
      return CalculationMethod.umm_al_qura.getParameters();
    case 'karachi':
      return CalculationMethod.karachi.getParameters();
    default:
      // وزارة الشؤون الدينية الجزائرية: الفجر 18° والعشاء 17°
      final p = CalculationMethod.other.getParameters();
      p.fajrAngle = 18.0;
      p.ishaAngle = 17.0;
      return p;
  }
}

class DayTimes {
  final Map<PrayerId, DateTime> _t;
  DayTimes(this._t);
  DateTime operator [](PrayerId id) => _t[id]!;
}

DayTimes computeDay(double lat, double lon, DateTime date, String method) {
  final pt = PrayerTimes(
    Coordinates(lat, lon),
    DateComponents(date.year, date.month, date.day),
    paramsFor(method),
  );
  return DayTimes({
    PrayerId.fajr: pt.fajr.toLocal(),
    PrayerId.sunrise: pt.sunrise.toLocal(),
    PrayerId.dhuhr: pt.dhuhr.toLocal(),
    PrayerId.asr: pt.asr.toLocal(),
    PrayerId.maghrib: pt.maghrib.toLocal(),
    PrayerId.isha: pt.isha.toLocal(),
  });
}

class NextInfo {
  final PrayerId id;
  final DateTime at;
  final DateTime prev;
  const NextInfo(this.id, this.at, this.prev);
}

NextInfo nextPrayer(double lat, double lon, String method, DateTime now) {
  final today = computeDay(lat, lon, now, method);
  for (var i = 0; i < fivePrayers.length; i++) {
    final t = today[fivePrayers[i]];
    if (now.isBefore(t)) {
      final prev = i == 0
          ? computeDay(lat, lon, DateTime(now.year, now.month, now.day - 1), method)[PrayerId.isha]
          : today[fivePrayers[i - 1]];
      return NextInfo(fivePrayers[i], t, prev);
    }
  }
  final tomorrow = computeDay(lat, lon, DateTime(now.year, now.month, now.day + 1), method);
  return NextInfo(PrayerId.fajr, tomorrow[PrayerId.fajr], today[PrayerId.isha]);
}
