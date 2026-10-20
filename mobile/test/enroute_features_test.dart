import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/services/app_settings_service.dart';
import 'package:mobile/services/fleet_state.dart';
import 'package:mobile/widgets/app_creator_footer.dart';

void main() {
  group('EnRoute New Features & Updations Verification', () {
    test('1. App Name is EnRoute and Translations are Accurate', () {
      final settings = AppSettingsService.instance;

      expect(settings.t('appName'), 'EnRoute');
      expect(settings.t('creators'), 'Created by Sahl Saleem & Fathima Riyas');

      // Switch to Malayalam
      settings.setLanguage('ml');
      expect(settings.isMalayalam, isTrue);
      expect(settings.t('appName'), contains('എൻറൂട്ട്'));
      expect(settings.t('creators'), contains('സാഹിൽ സലീം'));
      expect(settings.t('creators'), contains('ഫാത്തിമ റിയാസ്'));

      // Revert to English
      settings.setLanguage('en');
      expect(settings.isMalayalam, isFalse);
    });

    test('2. Dark Mode and Light Mode Toggle', () {
      final settings = AppSettingsService.instance;
      expect(settings.themeMode, isNotNull);

      final initial = settings.isDarkMode;
      settings.toggleTheme();
      expect(settings.isDarkMode, !initial);

      // Toggle back
      settings.toggleTheme();
      expect(settings.isDarkMode, initial);
    });

    testWidgets('3. AppCreatorFooter renders Sahl Saleem & Fathima Riyas with low opacity', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppCreatorFooter(),
          ),
        ),
      );

      expect(find.text('Created by Sahl Saleem & Fathima Riyas'), findsOneWidget);
      expect(find.text('EnRoute • Smart Kerala Transit System'), findsOneWidget);

      final opacityWidget = tester.widget<Opacity>(find.byType(Opacity));
      expect(opacityWidget.opacity, lessThan(0.5));
      expect(opacityWidget.opacity, greaterThanOrEqualTo(0.3));
    });

    test('4. Conductor can set current location/stop manually', () {
      final fleet = FleetState.instance;

      // Register or find bus
      final bus = fleet.buses.first;
      final originalStop = bus.currentStop;

      fleet.setBusManualCurrentStop(bus.regNumber, 'Palarivattom Bypass');
      expect(bus.currentStop, 'Palarivattom Bypass');
      expect(bus.conductorLocationString, contains('Manual Stop Override'));

      // Advance stage
      fleet.setBusManualCurrentStop(bus.regNumber, originalStop);
      expect(bus.currentStop, originalStop);
    });
  });
}
