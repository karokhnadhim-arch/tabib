import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../presentation/widgets/owner_module_app_bar.dart';

/// Placeholder for admin modules not yet fully implemented.
class SystemOwnerModulePlaceholderScreen extends StatelessWidget {
  const SystemOwnerModulePlaceholderScreen({
    super.key,
    required this.title,
    this.subtitle,
  });

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: ownerModuleAppBar(context, title: title),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.construction_outlined,
                  size: 56, color: Colors.grey.shade500),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
              const SizedBox(height: 16),
              Text(
                l10n.moduleComingSoon,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
