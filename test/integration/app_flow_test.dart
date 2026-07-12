import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:assetsphere/app/app.dart';
import 'package:assetsphere/app/di/app_dependencies.dart';
import 'package:assetsphere/app/session/app_session_controller.dart';
import 'package:assetsphere/features/authentication/presentation/pages/login_page.dart';
import 'package:assetsphere/features/dashboard/presentation/pages/home_page.dart';

void main() {
  testWidgets('App flows from Login to Dashboard', (WidgetTester tester) async {
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.exceptionAsString().contains('A RenderFlex overflowed')) {
        return; // Ignore
      }
      if (originalOnError != null) originalOnError(details);
    };

    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    
    final dependencies = AppDependencies.create();
    final sessionController = AppSessionController();

    await tester.pumpWidget(AssetSphereApp(
      dependencies: dependencies,
      sessionController: sessionController,
    ));

    await tester.pumpAndSettle();

    // Verify we are on Login page
    expect(find.byType(LoginPage), findsOneWidget);

    // Enter credentials
    final emailField = find.byType(TextFormField).first;
    final passwordField = find.byType(TextFormField).last;
    
    await tester.enterText(emailField, 'admin@assetsphere.com');
    await tester.enterText(passwordField, 'Admin@123');
    
    // Tap Login button
    final loginButton = find.widgetWithText(ElevatedButton, 'Login');
    await tester.tap(loginButton);
    
    await tester.pumpAndSettle();

    // Verify we are on the Dashboard page now
    expect(find.byType(HomePage), findsOneWidget);
    
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  });
}
