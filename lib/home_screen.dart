// Tela "Tela-inicial" do AppAgendamento (Figma node 102:51).
//
// Fontes: Manrope e Outfit (google_fonts).
//
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'confirm_agendamento.dart';

class _C {
  static const blueDark = Color(0xFF261CC1);
  static const navy = Color(0xFF264763);
  static const yellow = Color(0xFFFFD54A);
}

class _SpecialtyData {
  const _SpecialtyData({
    required this.name,
    required this.asset,
    required this.fallback,
  });

  final String name;
  final String? asset;
  final IconData fallback;
}

const _specialties = [
  _SpecialtyData(
    name: 'Clínico geral',
    asset: 'assets/especialista_clinico_geral.png',
    fallback: Icons.medical_services_outlined,
  ),
  _SpecialtyData(
    name: 'Cardiologia',
    asset: 'assets/especialista_cardiologia.png',
    fallback: Icons.favorite_border_rounded,
  ),
  _SpecialtyData(
    name: 'Oftalmologia',
    asset: 'assets/especialista_oftalmologia.png',
    fallback: Icons.visibility_outlined,
  ),
  _SpecialtyData(
    name: 'Dermatologia',
    asset: 'assets/especialista_dermatologia.png',
    fallback: Icons.healing_outlined,
  ),
  _SpecialtyData(
    name: 'Ginecologia e Obstetrícia',
    asset: 'assets/human-uterus.png',
    fallback: Icons.pregnant_woman_rounded,
  ),
  _SpecialtyData(
    name: 'Ortopedia',
    asset: 'assets/orthopedics.png',
    fallback: Icons.accessibility_new_rounded,
  ),
  _SpecialtyData(
    name: 'Pediatria',
    asset: 'assets/teddy-bear.png',
    fallback: Icons.child_care_rounded,
  ),
  _SpecialtyData(
    name: 'Oftalmologista',
    asset: 'assets/especialista_oftalmologia.png',
    fallback: Icons.visibility_outlined,
  ),
  _SpecialtyData(
    name: 'Psiquiatria',
    asset: 'assets/brain-organ.png',
    fallback: Icons.psychology_rounded,
  ),
];

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    this.userName = 'Maria',
    this.appointments = const [],
    this.availableSpecialties = const [],
    this.city,
    this.onSelectCity,
    this.onSearch,
    this.onScheduleAppointment,
    this.onLabExams,
    this.onOpenMap,
    this.onSeeAllSpecialties,
    this.onSpecialtyTap,
    this.onAppointmentDetails,
    this.onNavigate,
    this.showBottomNav = true,
  });

  final String userName;
  final List<AppointmentSummary> appointments;
  final List<String> availableSpecialties;

  /// Cidade escolhida. Quando nula, mostra "Selecionar cidade".
  final String? city;

  final VoidCallback? onSelectCity;
  final VoidCallback? onSearch;
  final VoidCallback? onScheduleAppointment;
  final VoidCallback? onLabExams;
  final VoidCallback? onOpenMap;
  final VoidCallback? onSeeAllSpecialties;
  final ValueChanged<String>? onSpecialtyTap;
  final ValueChanged<AppointmentSummary>? onAppointmentDetails;

  /// Índice da aba tocada: 0 Início, 1 Consultas, 2 Mensagens, 3 Perfil.
  final ValueChanged<int>? onNavigate;
  final bool showBottomNav;

  @override
  Widget build(BuildContext context) {
    final loadedSpecialties = availableSpecialties
        .map(_specialtyData)
        .toList(growable: false);
    final generalPractice = _specialties.first;
    final specialties = [
      generalPractice,
      ...loadedSpecialties.where(
        (specialty) =>
            _normalizeSpecialty(specialty.name) !=
            _normalizeSpecialty(generalPractice.name),
      ),
    ];
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: showBottomNav
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(26, 8, 26, 14),
                child: _BottomNav(selected: 0, onTap: onNavigate),
              ),
            )
          : null,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 6, bottom: 150),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 26),
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: _Greeting(
                    userName: userName,
                    city: city,
                    onSelectCity: onSelectCity,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: _ActionsPanel(
                  onSearch: onSearch,
                  onSchedule: onScheduleAppointment,
                  onLabExams: onLabExams,
                  onOpenMap: onOpenMap,
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 26),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Especialistas',
                        style: _outfit(20, FontWeight.w500, Colors.black, 28),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        if (onSeeAllSpecialties != null) {
                          onSeeAllSpecialties!();
                        } else {
                          _showAllSpecialties(
                            context,
                            specialties,
                            onSpecialtyTap,
                          );
                        }
                      },
                      child: Text(
                        'Ver todos',
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          height: 20 / 12,
                          color: const Color(0xFF214F83),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (specialties.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 26),
                  child: Text(
                    'Nenhuma especialidade com horários disponíveis.',
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (final specialty in specialties.take(4))
                        Expanded(
                          child: _Specialty(
                            specialty: specialty,
                            onTap: onSpecialtyTap,
                          ),
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: 33),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 26),
                child: Text(
                  'Suas consultas',
                  style: _outfit(20, FontWeight.w500, Colors.black, 28),
                ),
              ),
              const SizedBox(height: 13),
              if (appointments.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 26),
                  child: _NextAppointmentCard(
                    onSchedule: onScheduleAppointment,
                  ),
                )
              else
                for (final appointment in appointments)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(26, 0, 26, 12),
                    child: _NextAppointmentCard(
                      appointment: appointment,
                      onDetails: () => onAppointmentDetails?.call(appointment),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showAllSpecialties(
  BuildContext context,
  List<_SpecialtyData> specialties,
  ValueChanged<String>? onSpecialtyTap,
) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => DraggableScrollableSheet(
      initialChildSize: 0.82,
      minChildSize: 0.55,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFD8DDE7),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 18, 12, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Todas as especialidades',
                            style: GoogleFonts.manrope(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Encontre o cuidado ideal para você.',
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              color: const Color(0xFF627389),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Fechar',
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final itemWidth = (constraints.maxWidth - 40 - 20) / 3;
                    return SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 10,
                        runSpacing: 16,
                        children: [
                          for (final specialty in specialties)
                            SizedBox(
                              width: itemWidth,
                              height: 120,
                              child: _Specialty(
                                specialty: specialty,
                                onTap: (name) {
                                  Navigator.of(sheetContext).pop();
                                  onSpecialtyTap?.call(name);
                                },
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

TextStyle _outfit(
  double size,
  FontWeight weight,
  Color color,
  double lineHeight,
) => GoogleFonts.outfit(
  fontSize: size,
  fontWeight: weight,
  height: lineHeight / size,
  color: color,
);

_SpecialtyData _specialtyData(String name) {
  final normalized = _normalizeSpecialty(name);
  if (normalized.contains('otorrino')) {
    return const _SpecialtyData(
      name: 'Oftalmologista',
      asset: 'assets/especialista_oftalmologia.png',
      fallback: Icons.visibility_outlined,
    );
  }
  for (final item in _specialties) {
    final known = _normalizeSpecialty(item.name);
    if (normalized == known ||
        normalized.contains(known) ||
        known.contains(normalized) ||
        (normalized.contains('gineco') && known.contains('gineco'))) {
      return _SpecialtyData(
        name: item.name == 'Oftalmologista' ? item.name : name,
        asset: item.asset,
        fallback: item.fallback,
      );
    }
  }
  return _SpecialtyData(
    name: name,
    asset: null,
    fallback: Icons.medical_services_outlined,
  );
}

String _normalizeSpecialty(String value) => value
    .toLowerCase()
    .replaceAll(RegExp('[áàâãä]'), 'a')
    .replaceAll(RegExp('[éèêë]'), 'e')
    .replaceAll(RegExp('[íìîï]'), 'i')
    .replaceAll(RegExp('[óòôõö]'), 'o')
    .replaceAll(RegExp('[úùûü]'), 'u')
    .replaceAll('ç', 'c')
    .trim();

class _Greeting extends StatelessWidget {
  const _Greeting({required this.userName, this.city, this.onSelectCity});

  final String userName;
  final String? city;
  final VoidCallback? onSelectCity;

  @override
  Widget build(BuildContext context) {
    final initial = userName.isEmpty ? '' : userName[0].toUpperCase();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Olá, $userName!',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.manrope(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        height: 34 / 26,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Como você está se sentindo hoje?',
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        height: 20 / 13,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0x80F4CE14),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x0A345C85),
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  initial,
                  style: GoogleFonts.manrope(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF356B9C),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        InkWell(
          onTap: onSelectCity,
          child: Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 17,
                color: _C.blueDark,
              ),
              const SizedBox(width: 7),
              Text(
                'Localização',
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  height: 20 / 12,
                  color: _C.blueDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  city ?? 'Selecionar cidade',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 20 / 13,
                    color: _C.blueDark,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 16,
                color: _C.blueDark,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionsPanel extends StatelessWidget {
  const _ActionsPanel({
    this.onSearch,
    this.onSchedule,
    this.onLabExams,
    this.onOpenMap,
  });

  final VoidCallback? onSearch;
  final VoidCallback? onSchedule;
  final VoidCallback? onLabExams;
  final VoidCallback? onOpenMap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 316,
      child: Stack(
        children: [
          // Campo de busca (sem borda, só sombra)
          Positioned(
            left: 8,
            right: 8,
            top: 8,
            child: Material(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(20),
              elevation: 0,
              shadowColor: Colors.transparent,
              child: InkWell(
                onTap: onSearch,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  height: 52,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xCC000000),
                      width: 1,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x3342A5F5),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.search_rounded,
                        size: 22,
                        color: Colors.black,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Pesquisar profissionais ou clínicas',
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            height: 20 / 12,
                            color: const Color(0xFF6B7C90),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Os dois cartões de ação
          Positioned(
            left: 16,
            right: 16,
            top: 84,
            child: Row(
              children: [
                Expanded(
                  child: _ActionCard(
                    title: 'Agendar consulta',
                    subtitle: 'Encontre seu\nespecialista',
                    colors: const [Color(0xFF1E96FC), Color(0xFF072AC8)],
                    textColor: Colors.white,
                    titleFontSize: 19,
                    titleShadow: const Shadow(
                      color: Color(0x40000000),
                      offset: Offset(0, 2),
                      blurRadius: 4,
                    ),
                    onTap: onSchedule,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionCard(
                    title: 'Exames\nLaboratoriais',
                    subtitle: 'Marque\nseus exames',
                    colors: const [Color(0xE61D24CA), Color(0xE6201658)],
                    textColor: Colors.white,
                    titleShadow: const Shadow(
                      color: Color(0x40000000),
                      offset: Offset(0, 4),
                      blurRadius: 2,
                    ),
                    onTap: onLabExams,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            top: 248,
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: onOpenMap,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 58,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFDCE3EF)),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.map_outlined,
                        color: Color(0xFF2743BA),
                        size: 25,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mapa de clínicas',
                              style: GoogleFonts.manrope(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF162E93),
                              ),
                            ),
                            Text(
                              'Veja a distância até você',
                              style: GoogleFonts.manrope(
                                fontSize: 11,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFF64748B),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.colors,
    required this.textColor,
    required this.titleShadow,
    this.titleFontSize = 18,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final List<Color> colors;
  final Color textColor;
  final Shadow titleShadow;
  final double titleFontSize;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(15);

    return Container(
      height: 155,
      decoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(color: const Color(0x2E173C6A)),
        gradient: LinearGradient(colors: colors),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Stack(
            children: [
              Positioned(
                left: 13,
                top: 17,
                right: 12,
                child: Text(
                  title,
                  style: GoogleFonts.manrope(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w600,
                    height: 22 / titleFontSize,
                    color: textColor,
                    shadows: [titleShadow],
                  ),
                ),
              ),
              Positioned(
                left: 13,
                top: 75,
                child: Text(
                  subtitle,
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    height: 14 / 11,
                    color: textColor,
                  ),
                ),
              ),
              // Botão de seta num círculo translúcido
              Positioned(
                right: 13,
                bottom: 9,
                child: Container(
                  width: 34,
                  height: 29,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.chevron_right_rounded,
                    size: 22,
                    color: _C.yellow,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Specialty extends StatelessWidget {
  const _Specialty({required this.specialty, this.onTap});

  final _SpecialtyData specialty;
  final ValueChanged<String>? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap == null ? null : () => onTap!(specialty.name),
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x4D42A5F5),
                  blurRadius: 10,
                  offset: Offset(2, 4),
                ),
              ],
            ),
            child: specialty.asset == null
                ? Icon(specialty.fallback, size: 26, color: _C.navy)
                : Image.asset(
                    specialty.asset!,
                    width: 30,
                    height: 30,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) =>
                        Icon(specialty.fallback, size: 26, color: _C.navy),
                  ),
          ),
          const SizedBox(height: 8),
          Text(
            specialty.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              height: 18 / 11,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class _NextAppointmentCard extends StatelessWidget {
  const _NextAppointmentCard({
    this.appointment,
    this.onDetails,
    this.onSchedule,
  });

  final AppointmentSummary? appointment;
  final VoidCallback? onDetails;
  final VoidCallback? onSchedule;

  @override
  Widget build(BuildContext context) {
    final appointment = this.appointment;
    return Container(
      constraints: const BoxConstraints(minHeight: 162),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFEDF2FB), Color(0xFFABC4FF)],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(18, 17, 18, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  appointment == null
                      ? '—'
                      : appointment.doctorName
                            .split(' ')
                            .take(2)
                            .map((part) => part.isEmpty ? '' : part[0])
                            .join()
                            .toUpperCase(),
                  style: _outfit(
                    15,
                    FontWeight.w600,
                    const Color(0xFF42738F),
                    20.25,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment?.doctorName ?? 'Nenhuma consulta agendada',
                      style: _outfit(
                        18,
                        FontWeight.w600,
                        const Color(0xFF19354B),
                        24.3,
                      ),
                    ),
                    Text(
                      appointment == null
                          ? 'Quando você agendar, ela aparecerá aqui.'
                          : '${appointment.specialtyAndMode} · ${appointment.clinicName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        height: 16.2 / 12,
                        color: const Color(0xFF52677D),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 26,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Text(
                  appointment == null
                      ? 'Disponível'
                      : _daysUntil(appointment.scheduledAt),
                  style: GoogleFonts.manrope(fontSize: 11, color: Colors.black),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              const SizedBox(width: 2),
              const Icon(
                Icons.calendar_month_outlined,
                size: 18,
                color: Color(0xFF294B69),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  appointment == null
                      ? 'Nenhum horário marcado'
                      : _appointmentDateTime(appointment.scheduledAt),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _outfit(
                    13,
                    FontWeight.w600,
                    const Color(0xFF294B69),
                    17.55,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              onTap: appointment == null ? onSchedule : onDetails,
              borderRadius: BorderRadius.circular(18),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 40),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          appointment == null
                              ? 'Agendar consulta'
                              : 'Mais Informações',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: _outfit(
                            13,
                            FontWeight.w600,
                            const Color(0xFF214B68),
                            17.55,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 18,
                        color: Color(0xFF214B68),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _daysUntil(DateTime? date) {
    if (date == null) return 'Agendada';
    final today = DateTime.now();
    final days = DateTime(
      date.year,
      date.month,
      date.day,
    ).difference(DateTime(today.year, today.month, today.day)).inDays;
    if (days <= 0) return 'Hoje';
    if (days == 1) return 'Amanhã';
    return 'Em $days dias';
  }

  String _appointmentDateTime(DateTime? date) {
    if (date == null) return 'Horário confirmado';
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')} · '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.selected, this.onTap});

  final int selected;
  final ValueChanged<int>? onTap;

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.home_outlined, 'Início'),
      (Icons.calendar_month_outlined, 'Consultas'),
      (Icons.chat_bubble_outline_rounded, 'Mensagens'),
      (Icons.person_outline_rounded, 'Perfil'),
    ];

    return Container(
      height: 64,
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFE5EAF0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A173C6A),
            blurRadius: 20,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++)
            if (i == selected)
              Container(
                width: 112,
                height: 44,
                decoration: BoxDecoration(
                  color: _C.yellow,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: InkWell(
                  onTap: () => onTap?.call(i),
                  borderRadius: BorderRadius.circular(24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        items[i].$1,
                        size: 22,
                        color: const Color(0xFF173C6A),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        items[i].$2,
                        style: _outfit(
                          14,
                          FontWeight.w500,
                          const Color(0xFF173C6A),
                          18.9,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: InkWell(
                  onTap: () => onTap?.call(i),
                  borderRadius: BorderRadius.circular(24),
                  child: Center(
                    child: Icon(items[i].$1, size: 22, color: _C.navy),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
