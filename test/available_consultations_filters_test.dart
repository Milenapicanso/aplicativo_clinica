import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aplicativo_clinica/search_results_screen.dart';

void main() {
  testWidgets('available consultations filter by specialty and clinic', (
    WidgetTester tester,
  ) async {
    final consultations = SearchResponse(
      type: SearchResultType.available,
      professionals: [
        _professional(
          name: 'Dra. Ana Cardio',
          specialty: 'Cardiologia',
          clinic: 'Clínica Azul',
        ),
        _professional(
          name: 'Dr. Bruno Derma',
          specialty: 'Dermatologia',
          clinic: 'Clínica Verde',
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: SearchResultsScreen(
          query: '',
          response: Future.value(consultations),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Dra. Ana Cardio'), findsOneWidget);
    expect(find.text('Dr. Bruno Derma'), findsOneWidget);
    expect(find.text('Filtros'), findsNothing);

    await tester.tap(find.text('Especialistas'));
    await tester.pumpAndSettle();
    expect(find.text('Cardiologia'), findsWidgets);
    expect(find.text('Dermatologia'), findsWidgets);
    await tester.tap(find.text('Dermatologia').first);
    await tester.pumpAndSettle();
    expect(find.text('Dra. Ana Cardio'), findsNothing);
    expect(find.text('Dr. Bruno Derma'), findsOneWidget);

    await tester.tap(find.text('Clínicas'));
    await tester.pumpAndSettle();
    expect(find.text('Clínica Azul'), findsWidgets);
    expect(find.text('Clínica Verde'), findsWidgets);
    await tester.tap(find.text('Clínica Azul').first);
    await tester.pumpAndSettle();
    expect(find.text('Dra. Ana Cardio'), findsOneWidget);
    expect(find.text('Dr. Bruno Derma'), findsNothing);
  });
}

ProfessionalResult _professional({
  required String name,
  required String specialty,
  required String clinic,
}) => ProfessionalResult(
  name: name,
  specialty: specialty,
  rating: '—',
  reviewCount: 0,
  clinic: clinic,
  distance: 'Centro',
  mode: 'Disponível',
  nextSlot: '18/11 · 10:00',
  consultationId: '$name-id',
  doctorId: '$name-doctor',
  doctorCrm: null,
  clinicId: '$clinic-id',
  clinicPhone: null,
  scheduledAt: DateTime(2026, 11, 18, 10),
);
