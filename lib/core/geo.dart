import 'dart:math' as math;

const double _kaabaLat = 21.4225;
const double _kaabaLon = 39.8262;

double _rad(double d) => d * math.pi / 180;

/// اتجاه القبلة بالدرجات من الشمال الحقيقي (0..360).
double qiblaBearing(double lat, double lon) {
  final k = _rad(_kaabaLat), kl = _rad(_kaabaLon);
  final p = _rad(lat), l = _rad(lon);
  final y = math.sin(kl - l) * math.cos(k);
  final x = math.cos(p) * math.sin(k) - math.sin(p) * math.cos(k) * math.cos(kl - l);
  return (math.atan2(y, x) * 180 / math.pi + 360) % 360;
}

double distanceKm(double lat1, double lon1, double lat2, double lon2) {
  const r = 6371.0;
  final dLat = _rad(lat2 - lat1), dLon = _rad(lon2 - lon1);
  final a = math.pow(math.sin(dLat / 2), 2) +
      math.cos(_rad(lat1)) * math.cos(_rad(lat2)) * math.pow(math.sin(dLon / 2), 2);
  return 2 * r * math.asin(math.sqrt(a.toDouble()));
}

double distanceToKaabaKm(double lat, double lon) => distanceKm(lat, lon, _kaabaLat, _kaabaLon);
