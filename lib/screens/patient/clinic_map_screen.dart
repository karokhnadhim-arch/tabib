import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../services/clinic_data_service.dart';
import '../../services/location_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/localization_utils.dart';
import '../../widgets/common_widgets.dart';

class ClinicMapScreen extends StatefulWidget {
  const ClinicMapScreen({super.key, required this.clinicId});

  final String clinicId;

  @override
  State<ClinicMapScreen> createState() => _ClinicMapScreenState();
}

class _ClinicMapScreenState extends State<ClinicMapScreen> {
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
    final clinic = context.watch<ClinicDataService>().clinicById(widget.clinicId);
    if (clinic == null) {
      return Scaffold(body: Center(child: Text(l10n.errorGeneric)));
    }

    double? distanceKm;
    if (_position != null) {
      distanceKm = _locationService.distanceKm(
        fromLat: _position!.latitude,
        fromLng: _position!.longitude,
        toLat: clinic.latitude,
        toLng: clinic.longitude,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(clinic.name.localized(context)),
        backgroundColor: AppTheme.patientColor,
      ),
      body: _loading
          ? Center(child: Text(l10n.loading))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.patientColor.withOpacity(0.2),
                            AppTheme.accent.withOpacity(0.1),
                          ],
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.location_on, size: 64, color: AppTheme.patientColor),
                          const SizedBox(height: 8),
                          Text('${clinic.latitude.toStringAsFixed(4)}, ${clinic.longitude.toStringAsFixed(4)}'),
                          if (distanceKm != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                l10n.distanceKm(distanceKm.toStringAsFixed(1)),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(clinic.name.localized(context), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          InfoTile(icon: Icons.location_on_outlined, label: l10n.address, value: clinic.address.localized(context)),
                          const SizedBox(height: 8),
                          InfoTile(icon: Icons.phone_outlined, label: l10n.phone, value: clinic.phone),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _locationService.openInMaps(clinic),
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.patientColor),
                    icon: const Icon(Icons.map_outlined),
                    label: Text(l10n.openGoogleMaps),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => _locationService.openDirections(clinic),
                    icon: const Icon(Icons.navigation),
                    label: Text(l10n.gpsDirections),
                  ),
                ],
              ),
            ),
    );
  }
}
