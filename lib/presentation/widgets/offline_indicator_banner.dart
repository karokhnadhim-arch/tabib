import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../services/offline/connectivity_service.dart';

/// Compact offline banner — reliability indicator only.
class OfflineIndicatorBanner extends StatelessWidget {
  const OfflineIndicatorBanner({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final offline = context.watch<ConnectivityService>().isOffline;

    if (!offline) return const SizedBox.shrink();

    return Material(
      color: Colors.orange.shade800,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: compact ? 6 : 8,
          ),
          child: Row(
            children: [
              const Icon(Icons.cloud_off_outlined, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.offlineModeHint,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
