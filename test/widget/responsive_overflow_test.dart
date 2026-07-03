import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabib/core/widgets/responsive_scaffold.dart';
import 'package:tabib/l10n/app_localizations.dart';

void main() {
  Future<void> pumpSized(
    WidgetTester tester,
    Size size,
    Widget child,
  ) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  }

  const sizes = <Size>[
    Size(360, 800), // mobile
    Size(768, 1024), // tablet
    Size(1280, 800), // desktop
  ];

  for (final size in sizes) {
    testWidgets('ResponsiveInfoBanner at ${size.width}x${size.height}', (
      tester,
    ) async {
      await pumpSized(
        tester,
        size,
        ResponsiveInfoBanner(
          icon: const Icon(Icons.info_outline),
          message: const Text(
            'Complete your profile — add clinic name, address, hours, photos, and contact details.',
          ),
          trailing: TextButton(
            onPressed: () {},
            child: const Text('Complete profile'),
          ),
          backgroundColor: Colors.blue.shade50,
        ),
      );
    });

    testWidgets('ResponsiveActionButtons at ${size.width}x${size.height}', (
      tester,
    ) async {
      await pumpSized(
        tester,
        size,
        ResponsiveActionButtons(
          children: [
            FilledButton(onPressed: () {}, child: const Text('Edit profile')),
            OutlinedButton(
              onPressed: () {},
              child: const Text('View public profile'),
            ),
          ],
        ),
      );
    });

    testWidgets('ResponsiveColumns at ${size.width}x${size.height}', (
      tester,
    ) async {
      await pumpSized(
        tester,
        size,
        ResponsiveColumns(
          children: [
            Card(child: SizedBox(height: 80, child: Center(child: Text('A')))),
            Card(child: SizedBox(height: 80, child: Center(child: Text('B')))),
          ],
        ),
      );
    });
  }
}
