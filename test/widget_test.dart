// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:aplicativo_clinica/conectamed.dart';
import 'package:aplicativo_clinica/main.dart';
import 'package:aplicativo_clinica/onboarding_1.dart';
import 'package:aplicativo_clinica/registro.dart';
import 'package:aplicativo_clinica/Tela_login.dart';

void main() {
  testWidgets('ConectaMed is the first screen before onboarding', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const AppAgendamento());

    expect(find.byType(ConectaMedTelaInicial), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 2800));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(Onboarding1Tela), findsOneWidget);
  });

  testWidgets('onboarding access button opens login', (
    WidgetTester tester,
  ) async {
    await _openOnboarding(tester);

    await tester.ensureVisible(find.text('Acessar agora'));
    await tester.tap(find.text('Acessar agora'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('onboarding create account link opens registration', (
    WidgetTester tester,
  ) async {
    await _openOnboarding(tester);

    await tester.ensureVisible(find.text('Crie um agora'));
    await tester.tap(find.text('Crie um agora'));
    await tester.pumpAndSettle();

    expect(find.byType(RegisterPersonalScreen), findsOneWidget);
  });
}

Future<void> _openOnboarding(WidgetTester tester) async {
  await tester.pumpWidget(const AppAgendamento());
  await tester.pump(const Duration(milliseconds: 2800));
  await tester.pump(const Duration(milliseconds: 300));
}
