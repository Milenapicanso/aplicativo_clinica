import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'Tela_login.dart';
import 'registro.dart';
import 'confirm_agendamento.dart';
import 'home_screen.dart';
import 'onboarding_1.dart';
import 'doctor_profile_screen.dart';
import 'doctor_reviews_screen.dart';
import 'search_results_screen.dart';
import 'specialty_screen.dart';
import 'main_shell.dart';
import 'supabase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!SupabaseConfig.configurado) {
    throw StateError('Configure a URL e a chave pública do Supabase.');
  }

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
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

void _back(BuildContext context) => Navigator.of(context).maybePop();

// 2. ADICIONADO AQUI: Conecta o MainShell passando a sua HomeScreen com todos os callbacks
Widget _mainShell(BuildContext context) =>
    MainShell(homeScreen: _home(context, showBottomNav: false));

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
  onNext: (name, cpf, birthDate, sex) => _push(context, _registerAccess),
);

Widget _registerAccess(BuildContext context) => RegisterAccessScreen(
  onBack: () => _back(context),
  onFinish: (email, phone, password) => _goHome(context),
);

Widget _home(BuildContext context, {bool showBottomNav = true}) => HomeScreen(
  showBottomNav: showBottomNav,
  onSearch: () => _push(context, _searchResults),
  onScheduleAppointment: () => _push(context, _searchResults),
  onSpecialtyTap: (name) =>
      _push(context, (routeContext) => _specialty(routeContext, title: name)),
);

Widget _searchResults(BuildContext context) => SearchResultsScreen(
  onBack: () => _back(context),
  onSeeMore: (professional) => _push(context, _doctorProfile),
  onSchedule: (professional) => _push(context, _confirm),
);

Widget _specialty(BuildContext context, {String title = 'Cardiologia'}) =>
    SpecialtyScreen(
      title: title,
      onBack: () => _back(context),
      onTimeSelected: (professional, day, time) => _push(context, _confirm),
    );

Widget _doctorProfile(BuildContext context) => DoctorProfileScreen(
  onBack: () => _back(context),
  onSeeProfile: () => _push(context, _doctorReviews),
  onSeeReviews: () => _push(context, _doctorReviews),
  onSchedule: (day, time) => _push(context, _confirm),
);

Widget _doctorReviews(BuildContext context) =>
    DoctorReviewsScreen(onBack: () => _back(context));

Widget _confirm(BuildContext context) => ConfirmAppointmentScreen(
  onBack: () => _back(context),
  onChangeDateTime: () => _back(context),
  onConfirm: (confirmation) {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Consulta confirmada!')));
    _goHome(context);
  },
);
