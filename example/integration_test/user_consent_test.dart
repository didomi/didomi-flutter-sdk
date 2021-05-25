import 'package:didomi_sdk/didomi_sdk.dart';
import 'package:didomi_sdk/events/event_listener.dart';
import 'package:didomi_sdk_example/test/sample_for_user_consent_tests.dart' as userConsentApp;
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final initializeBtnFinder = find.byKey(Key("initializeSmall"));
  final agreeToAllBtnFinder = find.byKey(Key("setUserAgreeToAll"));
  final disagreeToAllBtnFinder = find.byKey(Key("setUserDisagreeToAll"));
  final userStatusBtnFinder = find.byKey(Key("setUserStatus"));

  bool isError = false;
  bool isReady = false;

  final listener = EventListener();
  listener.onError = (String message) {
    isError = true;
  };
  listener.onReady = () {
    isReady = true;
  };

  group("User Consent", () {
    testWidgets("Reset SDK for bulk action", (WidgetTester tester) async {
      try {
        DidomiSdk.reset();
      } catch (ignored) {}

      isError = false;
      isReady = false;

      DidomiSdk.addEventListener(listener);

      assert(isError == false);
      assert(isReady == false);
    });

    /*
     * Without initialization
     */

    testWidgets("Click agree to all without initialization", (WidgetTester tester) async {
      // Start userConsentApp
      userConsentApp.main();
      await tester.pumpAndSettle();

      assert(isError == false);
      assert(isReady == false);

      // Tap on Agree All button
      await tester.tap(agreeToAllBtnFinder);
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (Widget widget) =>
              widget is Text &&
              widget.key.toString().contains("setUserAgreeToAll") &&
              widget.data?.contains("Native message: Failed: \'Didomi SDK is not ready. Use the onReady callback to access this method.\'.") == true,
        ),
        findsOneWidget,
      );

      assert(isError == false);
      assert(isReady == false);
    });

    testWidgets("Click disagree to all without initialization", (WidgetTester tester) async {
      // Start userConsentApp
      userConsentApp.main();
      await tester.pumpAndSettle();

      assert(isError == false);
      assert(isReady == false);

      // Tap on Disagree All button
      await tester.tap(disagreeToAllBtnFinder);
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (Widget widget) =>
              widget is Text &&
              widget.key.toString().contains("setUserDisagreeToAll") &&
              widget.data?.contains("Native message: Failed: \'Didomi SDK is not ready. Use the onReady callback to access this method.\'.") == true,
        ),
        findsOneWidget,
      );

      assert(isError == false);
      assert(isReady == false);
    });

    testWidgets("Click user status without initialization", (WidgetTester tester) async {
      // Start userConsentApp
      userConsentApp.main();
      await tester.pumpAndSettle();

      assert(isError == false);
      assert(isReady == false);

      // Tap on User status button
      await tester.tap(userStatusBtnFinder);
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (Widget widget) =>
              widget is Text &&
              widget.key.toString().contains("setUserStatus") &&
              widget.data?.contains("Native message: Failed: \'Didomi SDK is not ready. Use the onReady callback to access this method.\'.") == true,
        ),
        findsOneWidget,
      );

      assert(isError == false);
      assert(isReady == false);
    });

    /*
     * With initialization
     */

    testWidgets("Initialize for following scenarios", (WidgetTester tester) async {
      // Start userConsentApp
      userConsentApp.main();
      await tester.pumpAndSettle();

      assert(isError == false);
      assert(isReady == false);

      await tester.tap(initializeBtnFinder);
      await tester.pumpAndSettle();

      await Future.delayed(Duration(seconds: 2));

      assert(isError == false);
      assert(isReady == true);
    });

    testWidgets("Click agree to all with initialization", (WidgetTester tester) async {
      // Start userConsentApp
      userConsentApp.main();
      await tester.pumpAndSettle();

      assert(isError == false);
      assert(isReady == true);

      // First click returns true
      await tester.tap(agreeToAllBtnFinder);
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (Widget widget) =>
              widget is Text && widget.key.toString().contains("setUserAgreeToAll") && widget.data?.contains("Native message: Consent updated: true.") == true,
        ),
        findsOneWidget,
      );

      assert(isError == false);
      assert(isReady == true);

      // Second click returns false
      await tester.tap(agreeToAllBtnFinder);
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (Widget widget) =>
              widget is Text && widget.key.toString().contains("setUserAgreeToAll") && widget.data?.contains("Native message: Consent updated: false.") == true,
        ),
        findsOneWidget,
      );

      assert(isError == false);
      assert(isReady == true);
    });

    testWidgets("Click disagree to all with initialization", (WidgetTester tester) async {
      // Start userConsentApp
      userConsentApp.main();
      await tester.pumpAndSettle();

      assert(isError == false);
      assert(isReady == true);

      // First click returns true
      await tester.tap(disagreeToAllBtnFinder);
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (Widget widget) =>
              widget is Text &&
              widget.key.toString().contains("setUserDisagreeToAll") &&
              widget.data?.contains("Native message: Consent updated: true.") == true,
        ),
        findsOneWidget,
      );

      assert(isError == false);
      assert(isReady == true);

      // Second click returns false
      await tester.tap(disagreeToAllBtnFinder);
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (Widget widget) =>
              widget is Text &&
              widget.key.toString().contains("setUserDisagreeToAll") &&
              widget.data?.contains("Native message: Consent updated: false.") == true,
        ),
        findsOneWidget,
      );

      assert(isError == false);
      assert(isReady == true);
    });

    testWidgets("Click user status all with initialization", (WidgetTester tester) async {
      // Start userConsentApp
      userConsentApp.main();
      await tester.pumpAndSettle();

      assert(isError == false);
      assert(isReady == true);

      // First click returns true
      await tester.tap(userStatusBtnFinder);
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (Widget widget) =>
              widget is Text && widget.key.toString().contains("setUserStatus") && widget.data?.contains("Native message: Consent updated: true.") == true,
        ),
        findsOneWidget,
      );

      assert(isError == false);
      assert(isReady == true);

      // Second click returns false
      await tester.tap(userStatusBtnFinder);
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (Widget widget) =>
              widget is Text && widget.key.toString().contains("setUserStatus") && widget.data?.contains("Native message: Consent updated: false.") == true,
        ),
        findsOneWidget,
      );

      assert(isError == false);
      assert(isReady == true);
    });
  });
}