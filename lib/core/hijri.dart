import 'dart:math' as math;

/// تحويل هجري/ميلادي بالتقويم الجدولي (مدني). قد يختلف يومًا عن الرؤية،
/// لذلك يوجد `adjust` يضبطه المستخدم من الإعدادات.
class HijriDate {
  final int year, month, day;
  const HijriDate(this.year, this.month, this.day);
}

int _gregorianToJdn(int y, int m, int d) {
  final a = (14 - m) ~/ 12;
  final yy = y + 4800 - a;
  final mm = m + 12 * a - 3;
  return d + (153 * mm + 2) ~/ 5 + 365 * yy + yy ~/ 4 - yy ~/ 100 + yy ~/ 400 - 32045;
}

double _islamicToJd(int y, int m, int d) =>
    d + (29.5 * (m - 1)).ceil() + (y - 1) * 354 + ((3 + 11 * y) ~/ 30) + 1948439.5 - 1;

HijriDate hijriFromDate(DateTime date, {int adjust = 0}) {
  final d = DateTime.utc(date.year, date.month, date.day + adjust);
  final jd = _gregorianToJdn(d.year, d.month, d.day) - 0.5;
  final year = ((30 * (jd - 1948439.5) + 10646) / 10631).floor();
  final month = math.min(12, ((jd - (29 + _islamicToJd(year, 1, 1))) / 29.5).ceil() + 1);
  final day = (jd - _islamicToJd(year, month, 1)).round() + 1;
  return HijriDate(year, month, day);
}

DateTime hijriToGregorian(int y, int m, int d, {int adjust = 0}) {
  final jdn = (_islamicToJd(y, m, d) + 0.5).floor();
  final u = DateTime.utc(1970, 1, 1).add(Duration(days: jdn - 2440588));
  return DateTime(u.year, u.month, u.day - adjust);
}

int hijriMonthLength(int y, int m, {int adjust = 0}) {
  final ny = m == 12 ? y + 1 : y;
  final nm = m == 12 ? 1 : m + 1;
  final a = hijriToGregorian(y, m, 1, adjust: adjust);
  final b = hijriToGregorian(ny, nm, 1, adjust: adjust);
  return DateTime.utc(b.year, b.month, b.day).difference(DateTime.utc(a.year, a.month, a.day)).inDays;
}

class RamadanInfo {
  final bool inRamadan;
  final int day;
  final int daysTo;
  final int hijriYear;
  const RamadanInfo(this.inRamadan, this.day, this.daysTo, this.hijriYear);
}

RamadanInfo ramadanInfo(DateTime now, int adjust) {
  final h = hijriFromDate(now, adjust: adjust);
  if (h.month == 9) return RamadanInfo(true, h.day, 0, h.year);
  final y = h.month < 9 ? h.year : h.year + 1;
  final start = hijriToGregorian(y, 9, 1, adjust: adjust);
  final days = DateTime.utc(start.year, start.month, start.day)
      .difference(DateTime.utc(now.year, now.month, now.day))
      .inDays;
  return RamadanInfo(false, 0, days, y);
}

class Occasion {
  final int month, day;
  final String key;
  const Occasion(this.month, this.day, this.key);
}

/// مناسبات متفق عليها فقط.
const kOccasions = [
  Occasion(1, 1, 'occ_newyear'),
  Occasion(1, 10, 'occ_ashura'),
  Occasion(9, 1, 'occ_ramadan'),
  Occasion(9, 27, 'occ_qadr'),
  Occasion(10, 1, 'occ_fitr'),
  Occasion(12, 9, 'occ_arafah'),
  Occasion(12, 10, 'occ_adha'),
];
