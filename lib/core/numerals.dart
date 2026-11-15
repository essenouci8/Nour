import 'app_state.dart';

const _arDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

/// يحوّل الأرقام اللاتينية إلى هندية عند اللغة العربية.
String nd(Object? v) {
  final s = '$v';
  if (AppState.instance.lang != 'ar') return s;
  return s.replaceAllMapped(RegExp(r'\d'), (m) => _arDigits[int.parse(m[0]!)]);
}

String pad2(int n) => n.toString().padLeft(2, '0');

/// الأوقات تُعرض بأرقام لاتينية دائمًا لسهولة القراءة.
String fmtTime(DateTime d) => '${pad2(d.hour)}:${pad2(d.minute)}';

String fmtDuration(Duration d) {
  final s = d.inSeconds < 0 ? 0 : d.inSeconds;
  return '${pad2(s ~/ 3600)}:${pad2((s % 3600) ~/ 60)}:${pad2(s % 60)}';
}

/// يقرأ رقمًا يكتبه المستخدم بأرقام عربية أو لاتينية.
double? parseNum(String input) {
  var s = input.trim().replaceAll(',', '.').replaceAll('٫', '.');
  for (var i = 0; i < 10; i++) {
    s = s.replaceAll(_arDigits[i], '$i');
  }
  return double.tryParse(s);
}
