import 'package:amaano_bookverse_app/app.dart';
import 'package:amaano_bookverse_app/core/widgets/carved_bottom_nav.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
void expectHomeShell(WidgetTester tester) {
  expect(find.byType(CarvedBottomNav), findsOneWidget);
  expect(find.text('Home'), findsWidgets);
  expect(find.text('Books'), findsWidgets);
  expect(find.text('Audiobooks'), findsWidgets);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Splash shows on launch', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const AmaanoBookVerseApp());
    expect(find.text('Amaano BookVerse'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 3500));
    await tester.pumpAndSettle();
  });

  testWidgets('First launch goes to intro onboarding', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'hasSeenOnboarding': false});
    await tester.pumpWidget(const AmaanoBookVerseApp());
    await tester.pump(const Duration(milliseconds: 3500));
    await tester.pumpAndSettle();
    expect(find.text('Discover Digital Books'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
  });

  testWidgets('Returning user goes to Home', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'hasSeenOnboarding': true});
    await tester.pumpWidget(const AmaanoBookVerseApp());
    await tester.pump(const Duration(milliseconds: 3500));
    await tester.pumpAndSettle();
    expectHomeShell(tester);
    await tester.pump(const Duration(milliseconds: 200));
  });

  testWidgets('Intro Next navigates pages and Get Started opens Home',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'hasSeenOnboarding': false});
    await tester.pumpWidget(const AmaanoBookVerseApp());
    await tester.pump(const Duration(milliseconds: 3500));
    await tester.pumpAndSettle();

    expect(find.text('Discover Digital Books'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Learn Anywhere'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Access Premium Knowledge'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);

    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    expectHomeShell(tester);
    await tester.pump(const Duration(milliseconds: 200));

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('hasSeenOnboarding'), isTrue);
  });
}
