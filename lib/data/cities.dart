import '../core/app_state.dart';
import '../core/geo.dart';

class City {
  final String ar, en;
  final double lat, lon;
  const City(this.ar, this.en, this.lat, this.lon);
  String name(String lang) => lang == 'ar' ? ar : en;
}

const kCities = [
  City('الجزائر العاصمة', 'Algiers', 36.7538, 3.0588),
  City('وهران', 'Oran', 35.6971, -0.6308),
  City('قسنطينة', 'Constantine', 36.365, 6.6147),
  City('عنابة', 'Annaba', 36.9, 7.7667),
  City('البليدة', 'Blida', 36.47, 2.83),
  City('باتنة', 'Batna', 35.5559, 6.1741),
  City('سطيف', 'Sétif', 36.19, 5.41),
  City('تلمسان', 'Tlemcen', 34.8828, -1.3167),
  City('بجاية', 'Béjaïa', 36.7509, 5.0567),
  City('تيزي وزو', 'Tizi Ouzou', 36.7118, 4.0459),
  City('بسكرة', 'Biskra', 34.85, 5.7333),
  City('ورقلة', 'Ouargla', 31.95, 5.3333),
  City('غرداية', 'Ghardaïa', 32.4909, 3.6735),
  City('الجلفة', 'Djelfa', 34.6667, 3.25),
  City('مستغانم', 'Mostaganem', 35.9333, 0.0833),
  City('سيدي بلعباس', 'Sidi Bel Abbès', 35.19, -0.63),
  City('تبسة', 'Tébessa', 35.4, 8.1167),
  City('جيجل', 'Jijel', 36.8206, 5.7667),
  City('سكيكدة', 'Skikda', 36.8762, 6.9092),
  City('أدرار', 'Adrar', 27.8743, -0.2939),
  City('تمنراست', 'Tamanrasset', 22.785, 5.5228),
  City('تونس', 'Tunis', 36.8065, 10.1815),
  City('طرابلس', 'Tripoli', 32.8872, 13.1913),
  City('الدار البيضاء', 'Casablanca', 33.5731, -7.5898),
  City('الرباط', 'Rabat', 34.0209, -6.8416),
  City('القاهرة', 'Cairo', 30.0444, 31.2357),
  City('الرياض', 'Riyadh', 24.7136, 46.6753),
  City('مكة المكرمة', 'Makkah', 21.3891, 39.8579),
  City('المدينة المنورة', 'Madinah', 24.5247, 39.5692),
  City('جدة', 'Jeddah', 21.4858, 39.1925),
  City('دبي', 'Dubai', 25.2048, 55.2708),
  City('الدوحة', 'Doha', 25.2854, 51.531),
  City('الكويت', 'Kuwait City', 29.3759, 47.9774),
  City('عمّان', 'Amman', 31.9454, 35.9284),
  City('بيروت', 'Beirut', 33.8938, 35.5018),
  City('دمشق', 'Damascus', 33.5138, 36.2765),
  City('بغداد', 'Baghdad', 33.3152, 44.3661),
  City('إسطنبول', 'Istanbul', 41.0082, 28.9784),
  City('باريس', 'Paris', 48.8566, 2.3522),
  City('مرسيليا', 'Marseille', 43.2965, 5.3698),
  City('لندن', 'London', 51.5072, -0.1276),
  City('بروكسل', 'Brussels', 50.8503, 4.3517),
  City('مونتريال', 'Montreal', 45.5017, -73.5673),
  City('نيويورك', 'New York', 40.7128, -74.006),
];

/// أقرب مدينة ضمن 60 كم، أو -1.
int nearestCityId(double lat, double lon) {
  var best = -1;
  var bd = 60.0;
  for (var i = 0; i < kCities.length; i++) {
    final d = distanceKm(lat, lon, kCities[i].lat, kCities[i].lon);
    if (d < bd) {
      bd = d;
      best = i;
    }
  }
  return best;
}

String cityLabel(AppState s, String myLocation) {
  if (s.cityId >= 0 && s.cityId < kCities.length) return kCities[s.cityId].name(s.lang);
  return myLocation;
}
