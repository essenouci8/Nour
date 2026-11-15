import 'package:geolocator/geolocator.dart';

import '../core/app_state.dart';
import '../data/cities.dart';

class LocationService {
  /// الموقع الحالي، أو null إذا رُفض الإذن أو الخدمة مغلقة.
  static Future<({double lat, double lon})?> current() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) return null;
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 20),
        ),
      );
      return (lat: pos.latitude, lon: pos.longitude);
    } catch (_) {
      return null;
    }
  }

  /// يحدّث الموقع من الـ GPS ويحفظه. يرجع true عند النجاح.
  static Future<bool> refresh() async {
    final pos = await current();
    if (pos == null) return false;
    AppState.instance.setLocation(pos.lat, pos.lon, city: nearestCityId(pos.lat, pos.lon), gps: true);
    return true;
  }
}
