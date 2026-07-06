import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';

/// Persistent side navigation for doctor and secretary clinical workspaces.
class ClinicalWorkspaceShell extends StatelessWidget {
  const ClinicalWorkspaceShell({
    super.key,
    required this.title,
    required this.accentColor,
    required this.selectedIndex,
    required this.destinations,
    required this.onDestinationSelected,
    required this.body,
    this.actions = const [],
    this.leading,
  });

  final String title;
  final Color accentColor;
  final int selectedIndex;
  final List<ClinicalNavDestination> destinations;
  final ValueChanged<int> onDestinationSelected;
  final Widget body;
  final List<Widget> actions;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide =
            constraints.maxWidth >= AppConstants.clinicalDesktopBreakpoint;
        if (!wide) {
          return Scaffold(
            appBar: AppBar(
              title: Text(title),
              backgroundColor: accentColor,
              leading: leading,
              actions: actions,
            ),
            body: body,
          );
        }

        final extended =
            constraints.maxWidth >= AppConstants.threePaneBreakpoint;

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              NavigationRail(
                extended: extended,
                minWidth: AppConstants.clinicalNavWidth,
                minExtendedWidth: AppConstants.clinicalNavExtendedWidth,
                selectedIndex: selectedIndex,
                onDestinationSelected: onDestinationSelected,
                labelType: extended
                    ? NavigationRailLabelType.none
                    : NavigationRailLabelType.selected,
                backgroundColor: accentColor.withOpacity(0.06),
                selectedIconTheme: IconThemeData(color: accentColor),
                selectedLabelTextStyle: TextStyle(
                  color: accentColor,
                  fontWeight: FontWeight.w600,
                ),
                leading: leading,
                destinations: [
                  for (final d in destinations)
                    NavigationRailDestination(
                      icon: Icon(d.icon),
                      selectedIcon: Icon(d.selectedIcon ?? d.icon),
                      label: Text(d.label),
                    ),
                ],
              ),
              const VerticalDivider(width: 1),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Material(
                      color: accentColor,
                      elevation: 0,
                      child: SafeArea(
                        bottom: false,
                        child: SizedBox(
                          height: 56,
                          child: Row(
                            children: [
                              const SizedBox(width: 20),
                              Expanded(
                                child: Text(
                                  destinations[selectedIndex].label,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                              ...actions,
                              const SizedBox(width: 8),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(child: body),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ClinicalNavDestination {
  const ClinicalNavDestination({
    required this.icon,
    required this.label,
    this.selectedIcon,
  });

  final IconData icon;
  final IconData? selectedIcon;
  final String label;
}
