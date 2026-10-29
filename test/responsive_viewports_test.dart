import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pairly/core/theme/app_theme.dart';
import 'package:pairly/core/widgets/custom_bottom_nav.dart';
import 'package:pairly/core/widgets/location_sharing_card.dart';

void main() {
  const viewports = [
    Size(320, 640), // Small phone (iPhone SE / compact Android)
    Size(360, 800), // Standard phone
    Size(412, 915), // Large phone (Pixel / Galaxy Ultra)
  ];

  for (final size in viewports) {
    group('Viewport Responsiveness at ${size.width}x${size.height}', () {
      testWidgets('CustomBottomNav renders without overflow',
          (WidgetTester tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.romanticTheme,
            home: Scaffold(
              bottomNavigationBar: CustomBottomNav(
                currentIndex: 0,
                onTap: (_) {},
              ),
            ),
          ),
        );

        expect(find.byType(CustomBottomNav), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('LocationSharingCard renders without overflow in narrow spaces',
          (WidgetTester tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.romanticTheme,
            home: Scaffold(
              body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: LocationSharingCard(
                  isSharing: true,
                  partnerName: 'Zarin Sultana Extremely Long Romantic Name',
                  lastUpdate: DateTime.now().subtract(const Duration(minutes: 5)),
                  accuracyMeters: 14.5,
                  isLoading: false,
                  onToggleSharing: () {},
                ),
              ),
            ),
          ),
        );

        expect(find.byType(LocationSharingCard), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });
  }
}
