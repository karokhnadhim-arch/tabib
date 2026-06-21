import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/doctor.dart';
import '../../services/location_service.dart';
import '../../utils/localization_utils.dart';

class DoctorLocationCard extends StatefulWidget {
  const DoctorLocationCard({super.key, required this.doctor});

  final Doctor doctor;

  @override
  State<DoctorLocationCard> createState() => _DoctorLocationCardState();
}

class _DoctorLocationCardState extends State<DoctorLocationCard> {
  final _locationService = LocationService();
  Position? _position;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    final pos = await _locationService.getCurrentPosition();
    if (mounted) {
      setState(() {
        _position = pos;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lat = widget.doctor.latitude ?? widget.doctor.clinic.latitude;
    final lng = widget.doctor.longitude ?? widget.doctor.clinic.longitude;

    double? distanceKm;
    if (_position != null) {
      distanceKm = _locationService.distanceKm(
        fromLat: _position!.latitude,
        fromLng: _position!.longitude,
        toLat: lat,
        toLng: lng,
      );
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.map_outlined,
                    color: AppTheme.medicalBlue, size: 22),
                const SizedBox(width: 8),
                Text(
                  l10n.clinicLocationGps,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 140,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.medicalBlue.withOpacity(0.25),
                      AppTheme.medicalGreen.withOpacity(0.15),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: _loading
                    ? Center(child: Text(l10n.loading))
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 48,
                            color: AppTheme.medicalBlue,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          if (distanceKm != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                l10n.distanceKm(distanceKm.toStringAsFixed(1)),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.medicalGreen,
                                ),
                              ),
                            ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.doctor.effectiveAddress.localized(context),
              style: TextStyle(height: 1.4, color: Colors.grey.shade800),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => _locationService.openCoordinatesInMaps(
                latitude: lat,
                longitude: lng,
              ),
              style:
                  FilledButton.styleFrom(backgroundColor: AppTheme.medicalBlue),
              icon: const Icon(Icons.map_outlined),
              label: Text(l10n.openGoogleMaps),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => _locationService.openDirectionsToCoordinates(
                latitude: lat,
                longitude: lng,
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.medicalGreen,
                side: const BorderSide(color: AppTheme.medicalGreen),
              ),
              icon: const Icon(Icons.navigation),
              label: Text(l10n.gpsDirections),
            ),
          ],
        ),
      ),
    );
  }
}
