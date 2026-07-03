import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:tabib/core/l10n/kurdish_material_localizations.dart';
import 'package:tabib/l10n/app_localizations.dart';
import 'package:tabib/presentation/widgets/profile_photo_crop_screen.dart';

void main() {
  Future<void> pumpCrop(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final image = img.Image(width: 1200, height: 900);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          KurdishMaterialLocalizationsDelegate(),
          KurdishWidgetsLocalizationsDelegate(),
          KurdishCupertinoLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: ProfilePhotoCropScreen(image: image),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  }

  testWidgets('ProfilePhotoCropScreen at 360x640 (Chrome-like)', (
    tester,
  ) async {
    await pumpCrop(tester, const Size(360, 640));
  });

  testWidgets('ProfilePhotoCropScreen at 1280x720 (desktop web)', (
    tester,
  ) async {
    await pumpCrop(tester, const Size(1280, 720));
  });
}
