import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pairly/core/theme/app_theme.dart';
import 'package:pairly/core/widgets/app_button.dart';
import 'package:pairly/core/widgets/app_card.dart';
import 'package:pairly/core/widgets/status_badge.dart';

void main() {
  testWidgets('App UI Components render and interact properly', (
    WidgetTester tester,
  ) async {
    bool buttonPressed = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: Center(
            child: AppCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const StatusBadge(type: StatusBadgeType.live),
                  const SizedBox(height: 12),
                  AppButton(
                    text: 'Tap Me',
                    onPressed: () {
                      buttonPressed = true;
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Live Location'), findsOneWidget);
    expect(find.text('Tap Me'), findsOneWidget);

    await tester.tap(find.text('Tap Me'));
    await tester.pump();

    expect(buttonPressed, isTrue);
  });
}
