import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aplicativo_clinica/confirm_agendamento.dart';
import 'package:aplicativo_clinica/home_screen.dart';

void main() {
  testWidgets('home keeps general practice and applies requested styling', (
    WidgetTester tester,
  ) async {
    final today = DateTime.now();
    final appointmentDate = DateTime(
      today.year,
      today.month,
      today.day + 4,
      10,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          availableSpecialties: const [
            'Dermatologia',
            'Otorrinolaringologia',
            'Oftalmologia',
          ],
          appointments: [
            AppointmentSummary(
              doctorName: 'Dra. Teste',
              specialtyAndMode: 'Dermatologia · Presencial',
              dateLabel: 'Consulta',
              timeLabel: 'às 10h',
              clinicName: 'Clínica',
              clinicAddress: 'Rua de Teste',
              price: 'R\$ 100',
              scheduledAt: appointmentDate,
            ),
          ],
          showBottomNav: false,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Clínico geral'), findsOneWidget);
    expect(find.text('Dermatologia'), findsOneWidget);
    expect(find.text('Oftalmologista'), findsOneWidget);

    final scheduleLabel = tester.widget<Text>(find.text('Agendar consulta'));
    expect(scheduleLabel.style?.color, Colors.white);
    expect(scheduleLabel.style?.fontSize, 19);

    final actionCard = tester.widget<Container>(
      find
          .ancestor(
            of: find.text('Agendar consulta'),
            matching: find.byType(Container),
          )
          .first,
    );
    final actionDecoration = actionCard.decoration! as BoxDecoration;
    expect(actionDecoration.gradient!.colors, const [
      Color(0xFF1E96FC),
      Color(0xFF072AC8),
    ]);
    expect(actionDecoration.boxShadow, isNull);

    expect(find.text('Em 4 dias'), findsOneWidget);
    final appointmentBadge = tester.widget<Container>(
      find
          .ancestor(
            of: find.text('Em 4 dias'),
            matching: find.byType(Container),
          )
          .first,
    );
    expect((appointmentBadge.decoration! as BoxDecoration).color, Colors.white);

    final generalIcon = tester.widget<Image>(
      find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName ==
                'assets/especialista_clinico_geral.png',
      ),
    );
    expect(generalIcon.width, 30);
    expect(generalIcon.height, 30);
    expect(generalIcon.fit, BoxFit.contain);
  });

  testWidgets('empty appointment card opens available consultations', (
    WidgetTester tester,
  ) async {
    var openedAvailableConsultations = false;
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          showBottomNav: false,
          onScheduleAppointment: () => openedAvailableConsultations = true,
        ),
      ),
    );

    final scheduleButton = find.text('Agendar consulta').last;
    await tester.ensureVisible(scheduleButton);
    await tester.tap(scheduleButton);

    expect(openedAvailableConsultations, isTrue);
  });

  testWidgets('map shortcut opens the map from the home actions', (
    WidgetTester tester,
  ) async {
    var openedMap = false;
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          showBottomNav: false,
          onOpenMap: () => openedMap = true,
        ),
      ),
    );

    final mapButton = find.text('Mapa de clínicas');
    await tester.ensureVisible(mapButton);
    await tester.tap(mapButton);

    expect(openedMap, isTrue);
  });

  testWidgets('Mais Informações invokes the appointment details callback', (
    WidgetTester tester,
  ) async {
    var openedAppointmentDetails = false;
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          showBottomNav: false,
          appointments: const [AppointmentSummary.sample],
          onAppointmentDetails: (_) => openedAppointmentDetails = true,
        ),
      ),
    );

    final detailsButton = find.text('Mais Informações');
    await tester.ensureVisible(detailsButton);
    await tester.tap(detailsButton);

    expect(openedAppointmentDetails, isTrue);
  });

  testWidgets('appointment card expands when text is scaled', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
          child: HomeScreen(
            showBottomNav: false,
            appointments: const [AppointmentSummary.sample],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('Ver todos centers the last incomplete specialty row', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          availableSpecialties: const [
            'Dermatologia',
            'Otorrinolaringologia',
            'Oftalmologia',
          ],
          showBottomNav: false,
        ),
      ),
    );
    await tester.tap(find.text('Ver todos'));
    await tester.pumpAndSettle();

    final lastSpecialty = find.text('Oftalmologia').last;
    expect(tester.getCenter(lastSpecialty).dx, closeTo(195, 1));
  });

  testWidgets('Suas consultas displays all scheduled appointments', (
    WidgetTester tester,
  ) async {
    final openedAppointments = <AppointmentSummary>[];
    const secondAppointment = AppointmentSummary(
      doctorName: 'Dr. Segundo',
      specialtyAndMode: 'Cardiologia · Presencial',
      dateLabel: '20/11/2026',
      timeLabel: 'às 14h',
      clinicName: 'Clínica Dois',
      clinicAddress: 'Rua Dois',
      price: 'R\$ 200',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          showBottomNav: false,
          appointments: [AppointmentSummary.sample, secondAppointment],
          onAppointmentDetails: openedAppointments.add,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Dra. Camila Ribeiro'), findsOneWidget);
    expect(find.text('Dr. Segundo'), findsOneWidget);
    expect(find.text('Mais Informações'), findsNWidgets(2));

    final secondDetailsButton = find.text('Mais Informações').last;
    await tester.ensureVisible(secondDetailsButton);
    await tester.tap(secondDetailsButton);

    expect(openedAppointments, [secondAppointment]);
  });
}
