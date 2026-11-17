import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'Tela_login.dart';
import 'registro.dart';
import 'confirm_agendamento.dart';
import 'appointment_details_screen.dart';
import 'home_screen.dart';
import 'onboarding_1.dart';
import 'doctor_profile_screen.dart';
import 'doctor_reviews_screen.dart';
import 'search_results_screen.dart';
import 'search_entry_screen.dart';
import 'specialty_screen.dart';
import 'main_shell.dart';
import 'supabase_repository.dart';
import 'supabase_client.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://ywzgtrfffnwjvoabrywu.supabase.co',
    publishableKey: 'sb_publishable_ay-m4tGXDZtGbKMOWNBx0Q_MCQh9OSE',
  );
  runApp(const AppAgendamento());
}

class AppAgendamento extends StatelessWidget {
  const AppAgendamento({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AppAgendamento',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF2743BA),
      ),
      home: Builder(builder: _onboarding),
    );
  }
}

typedef _Build = Widget Function(BuildContext context);

void _push(BuildContext context, _Build build) {
  Navigator.of(context).push(MaterialPageRoute<void>(builder: build));
}

// 1. ALTERADO AQUI: Agora vai para o MainShell (que contém a Home + Barra Inferior)
void _goHome(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute<void>(builder: _mainShell),
    (route) => false,
  );
}

void _goToOnboarding(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute<void>(builder: _onboarding),
    (route) => false,
  );
}

void _back(BuildContext context) => Navigator.of(context).maybePop();

// 2. ADICIONADO AQUI: Conecta o MainShell passando a sua HomeScreen com todos os callbacks
Widget _mainShell(BuildContext context) => MainShell(
  homeScreen: _home(context, showBottomNav: false),
  onSignOut: () => _goToOnboarding(context),
);

Widget _onboarding(BuildContext context) => Onboarding1Screen(
  onAccess: () => _push(context, _login),
  onCreateAccount: () => _push(context, _registerPersonal),
);

Widget _login(BuildContext context) => LoginScreen(
  onSubmit: (email, password) => _goHome(context),
  onRegister: () => _push(context, _registerPersonal),
);

Widget _registerPersonal(BuildContext context) => RegisterPersonalScreen(
  onBack: () => _back(context),
  onNext: (name, cpf, birthDate, sex) => _push(
    context,
    (registerContext) => _registerAccess(
      registerContext,
      name: name,
      cpf: cpf,
      birthDate: birthDate,
      sex: sex,
    ),
  ),
);

Widget _registerAccess(
  BuildContext context, {
  required String name,
  required String cpf,
  required String birthDate,
  required String? sex,
}) => RegisterAccessScreen(
  name: name,
  cpf: cpf,
  birthDate: birthDate,
  sex: sex,
  onBack: () => _back(context),
  onFinish: (email, phone, password) => _goHome(context),
);

Widget _home(BuildContext context, {bool showBottomNav = true}) =>
    _HomeDataLoader(
      showBottomNav: showBottomNav,
      onSearch: () => _push(context, _searchEntry),
      onScheduleAppointment: () => _push(context, _searchEntry),
      onAppointmentDetails: (appointment) => _push(
        context,
        (routeContext) =>
            _appointmentDetails(routeContext, appointment: appointment.summary),
      ),
      onSpecialtyTap: (name) => _push(
        context,
        (routeContext) => _specialty(routeContext, title: name),
      ),
    );

Widget _appointmentDetails(
  BuildContext context, {
  required AppointmentSummary appointment,
}) => AppointmentDetailsScreen(
  appointment: appointment,
  onBack: () => _back(context),
);

Widget _searchEntry(BuildContext context, {String initialQuery = ''}) =>
    SearchEntryScreen(
      initialQuery: initialQuery,
      onBack: () => _back(context),
      onSearch: (query) => _push(
        context,
        (resultsContext) => _searchResults(resultsContext, query: query),
      ),
    );

Widget _searchResults(BuildContext context, {required String query}) =>
    SearchResultsScreen(
      query: query,
      response: searchCatalog(query),
      onBack: () => _back(context),
      onChangeQuery: () => _push(
        context,
        (entryContext) => _searchEntry(entryContext, initialQuery: query),
      ),
      onSeeMore: (professional) => _push(
        context,
        (profileContext) =>
            _doctorProfile(profileContext, professional: professional),
      ),
      onSchedule: (professional) => _push(
        context,
        (confirmContext) => _confirm(
          confirmContext,
          appointment: professional.toAppointmentSummary(),
        ),
      ),
      onFavoriteDoctor: (professional) =>
          _addFavorite(context, doctorId: professional.doctorId),
      onFavoriteExam: (exam) => _addFavorite(context, examId: exam.id),
    );

Future<void> _addFavorite(
  BuildContext context, {
  String? doctorId,
  String? examId,
}) async {
  final user = supabase.auth.currentUser;
  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Entre na sua conta para salvar favoritos.'),
      ),
    );
    return;
  }

  final favorite = <String, Object>{'paciente_id': user.id};
  if (doctorId != null) favorite['medico_id'] = doctorId;
  if (examId != null) favorite['exame_id'] = examId;

  try {
    await supabase.from('favoritos').insert(favorite);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicionado aos favoritos.')),
      );
    }
  } on PostgrestException catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.code == '23505'
                ? 'Este item já está nos favoritos.'
                : error.message,
          ),
        ),
      );
    }
  }
}

Widget _specialty(BuildContext context, {String title = 'Cardiologia'}) =>
    _SpecialtyDataLoader(
      title: title,
      onBack: () => _back(context),
      onSchedule: (appointment) => _push(
        context,
        (confirmContext) => _confirm(confirmContext, appointment: appointment),
      ),
    );

Widget _doctorProfile(
  BuildContext context, {
  required ProfessionalResult professional,
}) {
  final date = professional.scheduledAt;
  final time =
      '${date.hour.toString().padLeft(2, '0')}h'
      '${date.minute.toString().padLeft(2, '0')}';
  return DoctorProfileScreen(
    doctor: DoctorProfile(
      name: professional.name,
      specialty: professional.specialty,
      rating: professional.rating,
      reviewCount: professional.reviewCount,
      clinicName: professional.clinic,
      addressLines: [professional.distance],
      phone: professional.clinicPhone ?? 'Telefone não informado',
      serviceType: professional.mode,
      serviceNotes: const ['Horários conforme disponibilidade cadastrada.'],
      consultationLabel: 'Consulta · ${professional.specialty}',
      price: professional.price ?? 'Consulte o valor',
      acceptedInsurances: const ['Consulte as condições com a clínica.'],
      paymentMethods: 'Consulte as formas de pagamento com a clínica.',
      returnPolicy: 'Consulte a política de retorno com a clínica.',
      cancellationPolicy: 'Consulte a política de cancelamento com a clínica.',
      documents: 'Consulte a clínica sobre os documentos necessários.',
      preparation: 'Consulte a clínica sobre o preparo.',
    ),
    month: DateTime(date.year, date.month),
    availableDays: {date.day},
    times: [time],
    onBack: () => _back(context),
    onSeeProfile: () => _push(
      context,
      (reviewContext) => _doctorReviews(
        reviewContext,
        doctorId: professional.doctorId,
        doctorName: professional.name,
        crm: professional.doctorCrm,
        specialty: professional.specialty,
      ),
    ),
    onSeeReviews: () => _push(
      context,
      (reviewContext) => _doctorReviews(
        reviewContext,
        doctorId: professional.doctorId,
        doctorName: professional.name,
        crm: professional.doctorCrm,
        specialty: professional.specialty,
      ),
    ),
    onSchedule: (day, selectedTime) => _push(
      context,
      (confirmContext) => _confirm(
        confirmContext,
        appointment: professional.toAppointmentSummary(),
      ),
    ),
  );
}

Widget _doctorReviews(
  BuildContext context, {
  required String doctorId,
  required String doctorName,
  required String? crm,
  required String specialty,
}) => _DoctorReviewsLoader(
  doctorId: doctorId,
  doctorName: doctorName,
  crm: crm,
  specialty: specialty,
  onBack: () => _back(context),
);

Widget _confirm(
  BuildContext context, {
  AppointmentSummary appointment = AppointmentSummary.sample,
}) => ConfirmAppointmentScreen(
  appointment: appointment,
  onBack: () => _back(context),
  onChangeDateTime: () => _back(context),
  onConfirm: (confirmation) async {
    final consultationId = appointment.consultationId;
    if (consultationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível identificar o horário.'),
        ),
      );
      return;
    }

    try {
      await supabase.rpc(
        'agendar_consulta',
        params: {
          'p_consulta_id': consultationId,
          'p_para_quem': confirmation.forSelf
              ? 'para mim'
              : confirmation.patient.name,
          'p_tipo_atendimento': confirmation.coverage == Coverage.insurance
              ? 'convenio'
              : 'particular',
        },
      );
      if (!context.mounted) return;
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (sheetContext) => FractionallySizedBox(
          heightFactor: 0.46,
          child: AppointmentConfirmationSheet(
            appointment: appointment,
            confirmation: confirmation,
          ),
        ),
      ).whenComplete(() {
        if (context.mounted) _goHome(context);
      });
    } on PostgrestException catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    }
  },
);

class _HomeDataLoader extends StatefulWidget {
  const _HomeDataLoader({
    required this.showBottomNav,
    required this.onSearch,
    required this.onScheduleAppointment,
    required this.onAppointmentDetails,
    required this.onSpecialtyTap,
  });

  final bool showBottomNav;
  final VoidCallback onSearch;
  final VoidCallback onScheduleAppointment;
  final ValueChanged<AppointmentRecord> onAppointmentDetails;
  final ValueChanged<String> onSpecialtyTap;

  @override
  State<_HomeDataLoader> createState() => _HomeDataLoaderState();
}

class _HomeDataLoaderState extends State<_HomeDataLoader> {
  late Future<_HomeData> _data;

  @override
  void initState() {
    super.initState();
    _data = _load();
  }

  Future<_HomeData> _load() async {
    final profile = await loadCurrentProfile();
    final appointments = await loadUpcomingAppointments();
    final specialties = await loadAvailableSpecialties();
    return _HomeData(
      profile: profile,
      appointment: appointments.isEmpty ? null : appointments.first,
      specialties: specialties,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_HomeData>(
      future: _data,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Não foi possível carregar seus dados.'),
                  TextButton(
                    onPressed: () => setState(() => _data = _load()),
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            ),
          );
        }

        final data = snapshot.data!;
        final fullName = data.profile?['nome'] as String?;
        final nameParts = (fullName ?? '').trim().split(RegExp(r'\s+'));
        final firstName = nameParts.first;
        final appointment = data.appointment;
        return HomeScreen(
          userName: firstName.isEmpty ? 'Paciente' : firstName,
          nextAppointment: appointment?.summary,
          availableSpecialties: data.specialties,
          showBottomNav: widget.showBottomNav,
          onSearch: widget.onSearch,
          onScheduleAppointment: widget.onScheduleAppointment,
          onAppointmentDetails: appointment == null
              ? null
              : () => widget.onAppointmentDetails(appointment),
          onSpecialtyTap: widget.onSpecialtyTap,
        );
      },
    );
  }
}

class _HomeData {
  const _HomeData({
    required this.profile,
    required this.appointment,
    required this.specialties,
  });

  final Map<String, dynamic>? profile;
  final AppointmentRecord? appointment;
  final List<String> specialties;
}

class _SpecialtyDataLoader extends StatefulWidget {
  const _SpecialtyDataLoader({
    required this.title,
    required this.onBack,
    required this.onSchedule,
  });

  final String title;
  final VoidCallback onBack;
  final ValueChanged<AppointmentSummary> onSchedule;

  @override
  State<_SpecialtyDataLoader> createState() => _SpecialtyDataLoaderState();
}

class _SpecialtyDataLoaderState extends State<_SpecialtyDataLoader> {
  late Future<SpecialtyAvailability> _availability;

  @override
  void initState() {
    super.initState();
    _availability = loadSpecialtyAvailability(widget.title);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SpecialtyAvailability>(
      future: _availability,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Não foi possível carregar os horários: ${snapshot.error}',
                  ),
                  TextButton(
                    onPressed: () => setState(
                      () => _availability = loadSpecialtyAvailability(
                        widget.title,
                      ),
                    ),
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            ),
          );
        }

        final availability = snapshot.data!;
        return SpecialtyScreen(
          title: widget.title,
          firstDay: availability.firstDay,
          professionals: availability.professionals,
          onBack: widget.onBack,
          onTimeSelected: (professional, day, time, consultationId) {
            final slot = professional
                .slotsFor(day)
                .firstWhere((slot) => slot.id == consultationId);
            widget.onSchedule(
              AppointmentSummary(
                consultationId: consultationId,
                scheduledAt: slot.dateTime,
                doctorName: professional.name,
                specialtyAndMode: '${professional.specialty} · Disponível',
                dateLabel:
                    '${slot.dateTime.day.toString().padLeft(2, '0')}/'
                    '${slot.dateTime.month.toString().padLeft(2, '0')}/'
                    '${slot.dateTime.year}',
                timeLabel:
                    'às ${slot.dateTime.hour.toString().padLeft(2, '0')}h'
                    '${slot.dateTime.minute.toString().padLeft(2, '0')}',
                clinicName: professional.clinicName,
                clinicAddress: professional.clinicAddress,
                price: professional.price,
              ),
            );
          },
        );
      },
    );
  }
}

class _DoctorReviewsLoader extends StatefulWidget {
  const _DoctorReviewsLoader({
    required this.doctorId,
    required this.doctorName,
    required this.crm,
    required this.specialty,
    required this.onBack,
  });

  final String doctorId;
  final String doctorName;
  final String? crm;
  final String specialty;
  final VoidCallback onBack;

  @override
  State<_DoctorReviewsLoader> createState() => _DoctorReviewsLoaderState();
}

class _DoctorReviewsLoaderState extends State<_DoctorReviewsLoader> {
  late Future<List<Map<String, dynamic>>> _reviews;

  @override
  void initState() {
    super.initState();
    _reviews = loadDoctorReviews(widget.doctorId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _reviews,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text(
                'Não foi possível carregar avaliações: ${snapshot.error}',
              ),
            ),
          );
        }

        final rows = snapshot.data ?? const [];
        final distribution = {
          for (var stars = 1; stars <= 5; stars++) stars: 0,
        };
        for (final row in rows) {
          final stars = (row['nota'] as num).toInt();
          distribution[stars] = (distribution[stars] ?? 0) + 1;
        }
        final average = rows.isEmpty
            ? 0.0
            : rows
                      .map((row) => (row['nota'] as num).toDouble())
                      .reduce((a, b) => a + b) /
                  rows.length;
        return DoctorReviewsScreen(
          doctorName: widget.doctorName,
          initials: widget.doctorName
              .split(RegExp(r'\s+'))
              .where((part) => part.isNotEmpty)
              .take(2)
              .map((part) => part[0])
              .join()
              .toUpperCase(),
          crm: widget.crm,
          specialties: [widget.specialty],
          rating: rows.isEmpty ? '—' : average.toStringAsFixed(1),
          distribution: distribution,
          reviews: [
            for (final row in rows)
              PatientReview(
                author: 'Paciente',
                date: _reviewDate(row['criada_em'] as String),
                mode: 'Avaliação de consulta',
                comment: row['comentario'] as String? ?? '',
                stars: (row['nota'] as num).toInt(),
              ),
          ],
          onBack: widget.onBack,
        );
      },
    );
  }

  String _reviewDate(String value) {
    final date = DateTime.parse(value).toLocal();
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
