import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Surah {
  final int number;
  final String name;
  final String english;
  final int ayahs;
  final String type; // Meccan | Medinan
  const Surah(this.number, this.name, this.english, this.ayahs, this.type);

  Map<String, dynamic> toJson() => {'n': number, 'a': name, 'e': english, 'c': ayahs, 't': type};
  factory Surah.fromJson(Map<String, dynamic> j) =>
      Surah(j['n'] as int, j['a'] as String, j['e'] as String, j['c'] as int, j['t'] as String);
}

class Ayah {
  final int number; // الترقيم العام (للصوت)
  final int inSurah;
  final int surah;
  final int page;
  final int juz;
  final String text;
  final String tafsir;
  const Ayah(this.number, this.inSurah, this.surah, this.page, this.juz, this.text, this.tafsir);

  Map<String, dynamic> toJson() =>
      {'n': number, 'i': inSurah, 's': surah, 'p': page, 'j': juz, 'x': text, 't': tafsir};
  factory Ayah.fromJson(Map<String, dynamic> j) => Ayah(j['n'] as int, j['i'] as int, j['s'] as int,
      j['p'] as int, j['j'] as int, j['x'] as String, j['t'] as String);
}

class SearchHit {
  final int surah;
  final String surahName;
  final int inSurah;
  final String text;
  const SearchHit(this.surah, this.surahName, this.inSurah, this.text);
}

class Reciter {
  final String id, ar, en;
  const Reciter(this.id, this.ar, this.en);
}

const kReciters = [
  Reciter('ar.alafasy', 'مشاري العفاسي', 'Mishary Alafasy'),
  Reciter('ar.husary', 'محمود خليل الحصري', 'Mahmoud Khalil Al-Husary'),
  Reciter('ar.minshawi', 'محمد صديق المنشاوي', 'Mohamed Siddiq Al-Minshawi'),
  Reciter('ar.abdulbasitmurattal', 'عبد الباسط عبد الصمد', 'Abdul Basit (Murattal)'),
];

/// بيانات المصحف من api.alquran.cloud (رسم عثماني + تفسير الميسر) مع تخزين محلي.
class QuranApi {
  static const _base = 'https://api.alquran.cloud/v1';
  static const _basmala = 'بِسْمِ';

  static Future<dynamic> _get(String path) async {
    final res = await http.get(Uri.parse('$_base$path')).timeout(const Duration(seconds: 25));
    if (res.statusCode != 200) throw Exception('HTTP ${res.statusCode}');
    final body = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    return body['data'];
  }

  static Future<List<Surah>> surahs() async {
    final p = await SharedPreferences.getInstance();
    final cached = p.getString('cache_surahs');
    if (cached != null) {
      return (jsonDecode(cached) as List).map((e) => Surah.fromJson(e as Map<String, dynamic>)).toList();
    }
    final data = await _get('/surah') as List;
    final list = data
        .map((e) => Surah(e['number'] as int, e['name'] as String, e['englishName'] as String,
            e['numberOfAyahs'] as int, e['revelationType'] as String))
        .toList();
    await p.setString('cache_surahs', jsonEncode(list.map((s) => s.toJson()).toList()));
    return list;
  }

  static List<Ayah> _merge(List data, {int? fallbackSurah}) {
    final text = (data[0]['ayahs'] as List);
    final taf = (data[1]['ayahs'] as List);
    final out = <Ayah>[];
    for (var i = 0; i < text.length; i++) {
      final a = text[i] as Map<String, dynamic>;
      final surah = (a['surah'] != null ? a['surah']['number'] : fallbackSurah) as int;
      var t = (a['text'] as String).trim();
      final inSurah = a['numberInSurah'] as int;
      // الآية الأولى تأتي مسبوقة بالبسملة في كل السور عدا الفاتحة والتوبة.
      if (inSurah == 1 && surah != 1 && surah != 9 && t.startsWith(_basmala)) {
        final words = t.split(' ');
        if (words.length > 4) t = words.sublist(4).join(' ');
      }
      out.add(Ayah(a['number'] as int, inSurah, surah, a['page'] as int, a['juz'] as int, t,
          i < taf.length ? (taf[i]['text'] as String).trim() : ''));
    }
    return out;
  }

  static Future<List<Ayah>> surah(int n) async {
    final p = await SharedPreferences.getInstance();
    final key = 'cache_surah_$n';
    final cached = p.getString(key);
    if (cached != null) {
      return (jsonDecode(cached) as List).map((e) => Ayah.fromJson(e as Map<String, dynamic>)).toList();
    }
    final data = await _get('/surah/$n/editions/quran-uthmani,ar.muyassar') as List;
    final list = _merge(data, fallbackSurah: n);
    await p.setString(key, jsonEncode(list.map((a) => a.toJson()).toList()));
    return list;
  }

  /// صفحة من المصحف (1..604) للورد اليومي.
  static Future<List<Ayah>> page(int n) async {
    final p = await SharedPreferences.getInstance();
    final key = 'cache_page_$n';
    final cached = p.getString(key);
    if (cached != null) {
      return (jsonDecode(cached) as List).map((e) => Ayah.fromJson(e as Map<String, dynamic>)).toList();
    }
    final data = await _get('/page/$n/editions/quran-uthmani,ar.muyassar') as List;
    final list = _merge(data);
    await p.setString(key, jsonEncode(list.map((a) => a.toJson()).toList()));
    return list;
  }

  static Future<List<SearchHit>> search(String q) async {
    final data = await _get('/search/${Uri.encodeComponent(q)}/all/quran-simple');
    final matches = (data['matches'] as List);
    return matches.take(60).map((m) {
      final s = m['surah'] as Map<String, dynamic>;
      return SearchHit(s['number'] as int, s['name'] as String, m['numberInSurah'] as int, m['text'] as String);
    }).toList();
  }

  static String audioUrl(String reciter, int globalAyah) =>
      'https://cdn.islamic.network/quran/audio/128/$reciter/$globalAyah.mp3';
}
