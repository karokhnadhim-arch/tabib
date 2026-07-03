import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';

/// Hub tile for a module subsection.
class OwnerHubItem {
  const OwnerHubItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.route,
    this.onTap,
    this.comingSoon = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? route;
  final VoidCallback? onTap;
  final bool comingSoon;
}

/// Reusable module hub with grouped administrative actions.
class OwnerModuleHubScreen extends StatelessWidget {
  const OwnerModuleHubScreen({
    super.key,
    required this.title,
    required this.items,
    this.header,
  });

  final String title;
  final String? header;
  final List<OwnerHubItem> items;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ColoredBox(
      color: const Color(0xFFF4F6F9),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          if (header != null) ...[
            Text(
              header!,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
            const SizedBox(height: 16),
          ],
          ...items.map(
            (item) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryDark.withOpacity(0.1),
                  child: Icon(item.icon, color: AppTheme.primaryDark),
                ),
                title: Text(item.title),
                subtitle: Text(item.subtitle),
                trailing: item.comingSoon
                    ? Chip(
                        label: Text(
                          l10n.comingSoon,
                          style: const TextStyle(fontSize: 11),
                        ),
                        visualDensity: VisualDensity.compact,
                      )
                    : const Icon(Icons.chevron_right),
                onTap: item.comingSoon
                    ? null
                    : () {
                        if (item.onTap != null) {
                          item.onTap!();
                        } else if (item.route != null) {
                          context.push(item.route!);
                        }
                      },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
