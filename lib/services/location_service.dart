import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/clinic.dart';

class LocationService {
  Future<Position?> getCurrentPosition() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return null;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;

    return Geolocator.getCurrentPosition();
  }

  double distanceKm({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
  }) {
    final meters = Geolocator.distanceBetween(fromLat, fromLng, toLat, toLng);
    return meters / 1000;
  }

  Future<bool> openInMaps(Clinic clinic) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${clinic.latitude},${clinic.longitude}',
    );
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<bool> openDirections(Clinic clinic) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${clinic.latitude},${clinic.longitude}',
    );
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
