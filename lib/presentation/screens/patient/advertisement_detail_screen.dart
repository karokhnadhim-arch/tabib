import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/advertisement.dart';
import '../../../services/advertisement_service.dart';
import '../../widgets/tabib_image.dart';

class AdvertisementDetailScreen extends StatelessWidget {
  const AdvertisementDetailScreen({super.key, required this.adId});

  final String adId;

  Advertisement? _findAd(BuildContext context) {
    final ads = context.read<AdvertisementService>().advertisements;
    for (final ad in ads) {
      if (ad.id == adId) return ad;
    }
    return null;
  }

  Future<void> _openLink(String? url) async {
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ad = _findAd(context);

    if (ad == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.advertisementDetails),
          backgroundColor: AppTheme.patientColor,
        ),
        body: Center(child: Text(l10n.advertisementNotFound)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.advertisementDetails),
        backgroundColor: AppTheme.patientColor,
      ),
      body: ListView(
        children: [
          if (ad.imageUrl != null && ad.imageUrl!.isNotEmpty)
            TabibImage(
              imageUrl: ad.imageUrl!,
              thumbnailUrl: ad.imageThumbnailUrl,
              height: 220,
              width: double.infinity,
              preferThumbnail: false,
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ad.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (ad.city != null && ad.city!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_city_outlined,
                          size: 18, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        ad.city!,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ],
                if (ad.description.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    ad.description,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          height: 1.5,
                          color: Colors.grey.shade800,
                        ),
                  ),
                ],
                if (ad.buttonLabel != null && ad.linkUrl != null) ...[
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => _openLink(ad.linkUrl),
                      icon: const Icon(Icons.open_in_new),
                      label: Text(ad.buttonLabel!),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
