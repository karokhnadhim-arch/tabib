import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabib/core/theme/app_theme.dart';
import 'package:tabib/core/widgets/responsive_scaffold.dart';
import 'package:tabib/l10n/app_localizations.dart';
import 'package:tabib/presentation/widgets/owner_metric_card.dart';

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

    testWidgets('Live Queue Statistics card at ${size.width}x${size.height}', (
      tester,
    ) async {
      final crossAxisCount = size.width >= 900 ? 5 : 2;
      final aspectRatio = size.width >= 900
          ? 1.22
          : size.width < 380
              ? 0.74
              : size.width < 600
                  ? 0.84
                  : 0.92;
      final cellWidth =
          (size.width - 32 - (crossAxisCount - 1) * 12) / crossAxisCount;
      final cellHeight = cellWidth / aspectRatio;

      await pumpSized(
        tester,
        size,
        SizedBox(
          width: cellWidth,
          height: cellHeight,
          child: OwnerMetricCard(
            label: 'Live queue statistics',
            value: '42',
            icon: Icons.queue_outlined,
            color: AppTheme.medicalBlue,
            subtitleContent: const OwnerQueueMetricDetails(
              waitingLabel: 'Waiting',
              waitingCount: 12,
              inProgressLabel: 'In progress',
              inProgressCount: 30,
            ),
            onTap: () {},
          ),
        ),
      );
    });

    testWidgets('OwnerMetricCard long Kurdish label at ${size.width}x${size.height}', (
      tester,
    ) async {
      final crossAxisCount = size.width >= 900 ? 5 : 2;
      final aspectRatio = size.width >= 900
          ? 1.22
          : size.width < 380
              ? 0.74
              : size.width < 600
                  ? 0.84
                  : 0.92;
      final cellWidth =
          (size.width - 32 - (crossAxisCount - 1) * 12) / crossAxisCount;
      final cellHeight = cellWidth / aspectRatio;

      await pumpSized(
        tester,
        size,
        SizedBox(
          width: cellWidth,
          height: cellHeight,
          child: OwnerMetricCard(
            label: 'ئاماری ڕیزی ڕاستەوخۆ',
            value: '99',
            icon: Icons.queue_outlined,
            color: AppTheme.medicalBlue,
            subtitleContent: const OwnerQueueMetricDetails(
              waitingLabel: 'چاوەڕوان',
              waitingCount: 5,
              inProgressLabel: 'لە جێبەجێکردندا',
              inProgressCount: 94,
            ),
          ),
        ),
      );
    });
  }
}
