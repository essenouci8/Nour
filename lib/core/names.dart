import '../services/prayer_service.dart';
import 'app_state.dart';
import 'hijri.dart';
import 'numerals.dart';

int get _li => const {'ar': 0, 'en': 1, 'fr': 2}[AppState.instance.lang] ?? 0;

const _weekdays = [
  ['الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'],
  ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'],
  ['lundi', 'mardi', 'mercredi', 'jeudi', 'vendredi', 'samedi', 'dimanche'],
];

const _gMonths = [
  ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'],
  ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'],
  ['janvier', 'février', 'mars', 'avril', 'mai', 'juin', 'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'],
];

const _hMonths = [
  ['محرم', 'صفر', 'ربيع الأول', 'ربيع الآخر', 'جمادى الأولى', 'جمادى الآخرة', 'رجب', 'شعبان', 'رمضان', 'شوال', 'ذو القعدة', 'ذو الحجة'],
  ['Muharram', 'Safar', "Rabi' I", "Rabi' II", 'Jumada I', 'Jumada II', 'Rajab', "Sha'ban", 'Ramadan', 'Shawwal', "Dhu al-Qi'dah", 'Dhu al-Hijjah'],
  ['Mouharram', 'Safar', 'Rabi I', 'Rabi II', 'Joumada I', 'Joumada II', 'Rajab', 'Chaabane', 'Ramadan', 'Chawwal', 'Dhou al-Qi`da', 'Dhou al-Hijja'],
];

const _prayers = [
  ['الفجر', 'الشروق', 'الظهر', 'العصر', 'المغرب', 'العشاء'],
  ['Fajr', 'Sunrise', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'],
  ['Fajr', 'Lever du soleil', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'],
];

const _dow = [
  ['ح', 'ن', 'ث', 'ر', 'خ', 'ج', 'س'],
  ['S', 'M', 'T', 'W', 'T', 'F', 'S'],
  ['D', 'L', 'M', 'M', 'J', 'V', 'S'],
];

/// weekday: DateTime.weekday (الاثنين = 1 ... الأحد = 7)
String weekdayName(int weekday) => _weekdays[_li][weekday - 1];
String gMonthName(int m) => _gMonths[_li][m - 1];
String hMonthName(int m) => _hMonths[_li][m - 1];
String prayerName(PrayerId id) => _prayers[_li][id.index];

/// حروف رؤوس الأسبوع بدءًا من الأحد.
List<String> weekdayInitialsSunFirst() => _dow[_li];

String gregorianLabel(DateTime d) =>
    '${weekdayName(d.weekday)} ${nd(d.day)} ${gMonthName(d.month)}';

String hijriLabel(HijriDate h) => '${nd(h.day)} ${hMonthName(h.month)} ${nd(h.year)}';

String fullGregorian(DateTime d) => '${nd(d.day)} ${gMonthName(d.month)} ${nd(d.year)}';
