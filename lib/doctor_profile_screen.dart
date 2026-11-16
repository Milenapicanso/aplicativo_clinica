// Tela "Perfil · Dra. Camila Ribeiro" / "Mais Informações" (Figma node 71:2).
//
// Fonte: Manrope (google_fonts).
// Foto: assets/images/dra_camila_ribeiro.png (exporte do Figma; sem o arquivo
// aparece um ícone no lugar).

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class _C {
  static const background = Color(0xFFEDF2FB);
  static const ink = Color(0xFF111827);
  static const slate700 = Color(0xFF334155);
  static const slate600 = Color(0xFF475569);
  static const slate500 = Color(0xFF64748B);
  static const border = Color(0xFFDCE3EF);
  static const navy = Color(0xFF162E93);
  static const blue = Color(0xFF261CC1);
  static const green = Color(0xFF23734C);
  static const amber = Color(0xFFB27A00);
}

class DoctorProfile {
  const DoctorProfile({
    required this.name,
    required this.specialty,
    required this.rating,
    required this.reviewCount,
    required this.clinicName,
    required this.addressLines,
    required this.phone,
    required this.serviceType,
    required this.serviceNotes,
    required this.consultationLabel,
    required this.price,
    required this.acceptedInsurances,
    required this.paymentMethods,
    required this.returnPolicy,
    required this.cancellationPolicy,
    required this.documents,
    required this.preparation,
    this.photoAsset,
  });

  final String name;
  final String specialty;
  final String rating;
  final int reviewCount;
  final String? photoAsset;
  final String clinicName;
  final List<String> addressLines;
  final String phone;
  final String serviceType;
  final List<String> serviceNotes;
  final String consultationLabel;
  final String price;
  final List<String> acceptedInsurances; // linhas de texto
  final String paymentMethods;
  final String returnPolicy;
  final String cancellationPolicy;
  final String documents;
  final String preparation;

  static const camila = DoctorProfile(
    name: 'Dra. Camila Ribeiro',
    specialty: 'Cardiologista',
    rating: '4,9',
    reviewCount: 128,
    photoAsset: 'assets/images/dra_camila_ribeiro.png',
    clinicName: 'Clínica Coração & Vida',
    addressLines: [
      'Rua do Cuidado, 120 · Sala 402',
      'Bela Vista, São Paulo – SP · CEP 01310-000',
    ],
    phone: '(11) 3000-0000',
    serviceType: 'Atendimento presencial',
    serviceNotes: [
      'Na clínica, com horário marcado.',
      'Chegue com 15 minutos de antecedência.',
    ],
    consultationLabel: 'Consulta particular · 30 min',
    price: 'R\$ 320',
    acceptedInsurances: [
      'Unimed · Bradesco Saúde · SulAmérica',
      'Seu convênio está entre os aceitos.',
    ],
    paymentMethods: 'Pix, cartão de débito ou crédito em até 2x.',
    returnPolicy: 'Retorno sem custo em até 30 dias, para o mesmo motivo da consulta.',
    cancellationPolicy:
        'Cancele ou remarque sem custo até 24h antes. Após esse prazo, fale com a clínica para consultar as condições.',
    documents: 'Documento com foto, carteirinha do convênio (se usar) e exames anteriores.',
    preparation:
        'Não é necessário jejum para a consulta. Caso haja exames, confirme o preparo com a clínica.',
  );
}

class DoctorProfileScreen extends StatefulWidget {
  DoctorProfileScreen({
    super.key,
    this.doctor = DoctorProfile.camila,
    DateTime? month,
    Set<int>? availableDays,
    this.times = const ['15h30', '16h30', '17h30'],
    this.acceptsUserInsurance = true,
    this.onBack,
    this.onSeeProfile,
    this.onSeeReviews,
    this.onSeeLocation,
    this.onSchedule,
  })  : month = month ?? DateTime(2026, 11),
        availableDays = availableDays ?? const {14, 16, 18, 20, 23, 25, 27, 30};

  final DoctorProfile doctor;

  /// Mês mostrado na agenda (só ano e mês importam).
  final DateTime month;

  /// Dias do mês com horário livre.
  final Set<int> availableDays;

  /// Horários mostrados para o dia escolhido.
  final List<String> times;

  /// Mostra "Aceita seu convênio" na barra inferior.
  final bool acceptsUserInsurance;

  final VoidCallback? onBack;
  final VoidCallback? onSeeProfile;
  final VoidCallback? onSeeReviews;
  final VoidCallback? onSeeLocation;

  /// Toque em "Agendar consulta", com o dia e o horário escolhidos (o horário pode ser nulo).
  final void Function(DateTime day, String? time)? onSchedule;

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  static const _months = [
    'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
    'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro',
  ];
  static const _weekdayNames = [
    'Segunda-feira', 'Terça-feira', 'Quarta-feira', 'Quinta-feira',
    'Sexta-feira', 'Sábado', 'Domingo',
  ];

  late int _selectedDay = widget.availableDays.contains(14)
      ? 14
      : (widget.availableDays.toList()..sort()).first;
  String? _selectedTime;

  @override
  Widget build(BuildContext context) {
    final d = widget.doctor;
    final selectedDate = DateTime(widget.month.year, widget.month.month, _selectedDay);

    return Scaffold(
      backgroundColor: _C.background,
      body: SafeArea(
        child: Column(
          children: [
            _Header(onBack: widget.onBack),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
                children: [
                  _IdentityCard(
                    doctor: d,
                    onSeeProfile: widget.onSeeProfile,
                    onSeeReviews: widget.onSeeReviews,
                  ),
                  const _Gap(),
                  _Section(
                    title: 'Sobre o atendimento',
                    child: _Card(
                      radius: 18,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _text(d.clinicName, 14, FontWeight.w600, _C.ink, 22),
                          const SizedBox(height: 9),
                          for (final line in d.addressLines)
                            _text(line, 12, FontWeight.w400, _C.slate600, 20),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: widget.onSeeLocation,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Row(
                                children: [
                                  const SizedBox(width: 0),
                                  const Icon(Icons.location_on_outlined, size: 18, color: _C.blue),
                                  const SizedBox(width: 8),
                                  _text('Ver localização e como chegar', 12, FontWeight.w600, _C.blue, 22),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          _text('Telefone da clínica: ${d.phone}', 12, FontWeight.w400, _C.slate600, 20),
                          const SizedBox(height: 13),
                          _text(d.serviceType, 13, FontWeight.w600, const Color(0xFF27C840), 22),
                          const SizedBox(height: 5),
                          for (final line in d.serviceNotes)
                            _text(line, 12, FontWeight.w400, _C.slate600, 20),
                        ],
                      ),
                    ),
                  ),
                  const _Gap(),
                  _Section(
                    title: 'Valores e pagamento',
                    child: _Card(
                      radius: 18,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _text(d.consultationLabel, 12, FontWeight.w500, _C.slate500, 20),
                          const SizedBox(height: 5),
                          _text(d.price, 26, FontWeight.w700, _C.ink, 34),
                          const SizedBox(height: 12),
                          _text('Convênios aceitos', 12, FontWeight.w600, _C.slate700, 20),
                          for (final line in d.acceptedInsurances)
                            _text(line, 12, FontWeight.w400, _C.green, 20),
                          const SizedBox(height: 7),
                          _text('Formas de pagamento', 12, FontWeight.w600, _C.slate700, 20),
                          const SizedBox(height: 3),
                          _text(d.paymentMethods, 12, FontWeight.w400, _C.slate600, 20),
                          const SizedBox(height: 13),
                          _text('Política de retorno', 12, FontWeight.w600, _C.slate700, 20),
                          const SizedBox(height: 3),
                          _text(d.returnPolicy, 12, FontWeight.w400, _C.slate600, 20),
                        ],
                      ),
                    ),
                  ),
                  const _Gap(),
                  _Section(
                    title: 'Agenda',
                    child: _Card(radius: 18, child: _buildCalendar(selectedDate)),
                  ),
                  const _Gap(),
                  _Section(
                    title: 'Avaliações',
                    child: InkWell(
                      onTap: widget.onSeeReviews,
                      borderRadius: BorderRadius.circular(18),
                      child: _Card(
                        radius: 18,
                        padding: const EdgeInsets.fromLTRB(15, 12, 15, 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 102,
                              child: _text('★ ${d.rating}', 25, FontWeight.w700, const Color(0xFF9B6A00), 34),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _text('${d.reviewCount} avaliações', 13, FontWeight.w600, _C.slate700, 22),
                                  _text('Ler comentários dos pacientes  →', 11, FontWeight.w600, _C.blue, 20),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const _Gap(),
                  _Section(
                    title: 'Regras e orientações',
                    child: _Card(
                      radius: 18,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _text('Cancelamento e remarcação', 13, FontWeight.w600, _C.slate700, 22),
                          const SizedBox(height: 7),
                          _text(d.cancellationPolicy, 12, FontWeight.w400, _C.slate600, 20),
                          const SizedBox(height: 14),
                          _text('Documentos para levar', 13, FontWeight.w600, _C.slate700, 22),
                          const SizedBox(height: 7),
                          _text(d.documents, 12, FontWeight.w400, _C.slate600, 20),
                          const SizedBox(height: 14),
                          _text('Preparo', 13, FontWeight.w600, _C.slate700, 22),
                          const SizedBox(height: 7),
                          _text(d.preparation, 12, FontWeight.w400, _C.slate600, 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _text('Perfil, registros e condições ilustrativos.', 11, FontWeight.w400, _C.slate500, 20),
                ],
              ),
            ),
            _BottomBar(
              acceptsInsurance: widget.acceptsUserInsurance,
              onPressed: () => widget.onSchedule?.call(selectedDate, _selectedTime),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar(DateTime selectedDate) {
    final month = widget.month;
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final offset = DateTime(month.year, month.month, 1).weekday - 1; // semana começa na segunda
    final rows = ((offset + daysInMonth) / 7).ceil();
    const headers = ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];

    Widget cell(int day) {
      if (day < 1 || day > daysInMonth) return const SizedBox(height: 27);
      final available = widget.availableDays.contains(day);
      final selected = day == _selectedDay;

      final Color? bg = selected ? _C.navy : (available ? const Color(0xFFEEF2FF) : null);
      final Color fg = selected
          ? Colors.white
          : (available ? _C.navy : const Color(0xFF9AA3B0));

      return Center(
        child: GestureDetector(
          onTap: available
              ? () => setState(() {
                    _selectedDay = day;
                    _selectedTime = null;
                  })
              : null,
          child: Container(
            width: 34,
            height: 27,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
            child: Text(
              '$day',
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: available || selected ? FontWeight.w700 : FontWeight.w400,
                color: fg,
              ),
            ),
          ),
        ),
      );
    }

    final weekdayName = _weekdayNames[selectedDate.weekday - 1];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _text('${_capitalize(_months[month.month - 1])} ${month.year}', 16, FontWeight.w700, _C.ink, 24),
        const SizedBox(height: 5),
        _text('Dias disponíveis em azul', 11, FontWeight.w400, _C.slate500, 18),
        const SizedBox(height: 7),
        Row(
          children: [
            for (final h in headers)
              Expanded(
                child: Center(child: _text(h, 11, FontWeight.w600, _C.slate500, 20)),
              ),
          ],
        ),
        const SizedBox(height: 6),
        for (var r = 0; r < rows; r++) ...[
          Row(
            children: [
              for (var c = 0; c < 7; c++) Expanded(child: cell(r * 7 + c - offset + 1)),
            ],
          ),
          const SizedBox(height: 2),
        ],
        const SizedBox(height: 14),
        _text(
          '$weekdayName, ${selectedDate.day} de ${_months[selectedDate.month - 1]}',
          13,
          FontWeight.w600,
          _C.ink,
          22,
        ),
        const SizedBox(height: 13),
        Row(
          children: [
            for (var i = 0; i < widget.times.length; i++) ...[
              if (i > 0) const SizedBox(width: 7),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedTime = widget.times[i]),
                  child: Container(
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _selectedTime == widget.times[i] ? _C.navy : const Color(0xFFF0F4FC),
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(
                        color: _selectedTime == widget.times[i] ? _C.navy : const Color(0xFFCFD9EC),
                      ),
                    ),
                    child: Text(
                      widget.times[i],
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _selectedTime == widget.times[i] ? Colors.white : _C.navy,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 14),
        _text('Horários de Brasília · atendimento presencial', 11, FontWeight.w400, _C.slate500, 20),
      ],
    );
  }

  static String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

Widget _text(String value, double size, FontWeight weight, Color color, double lineHeight) {
  return Text(
    value,
    style: GoogleFonts.manrope(
      fontSize: size,
      fontWeight: weight,
      height: lineHeight / size,
      color: color,
    ),
  );
}

class _Gap extends StatelessWidget {
  const _Gap();

  @override
  Widget build(BuildContext context) => const SizedBox(height: 20);
}

class _Header extends StatelessWidget {
  const _Header({this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 9, 16, 9),
      child: Row(
        children: [
          InkWell(
            onTap: onBack,
            borderRadius: BorderRadius.circular(20),
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Icon(Icons.chevron_left_rounded, size: 24, color: _C.navy),
            ),
          ),
          const SizedBox(width: 3),
          Text(
            'Mais Informações',
            style: GoogleFonts.manrope(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              height: 28 / 20,
              color: _C.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _text(title, 18, FontWeight.w700, _C.ink, 26),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({
    required this.child,
    this.radius = 18,
    this.padding = const EdgeInsets.all(15),
  });

  final Widget child;
  final double radius;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: _C.border),
      ),
      child: child,
    );
  }
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({required this.doctor, this.onSeeProfile, this.onSeeReviews});

  final DoctorProfile doctor;
  final VoidCallback? onSeeProfile;
  final VoidCallback? onSeeReviews;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      color: const Color(0xFFE5EEF9),
      alignment: Alignment.center,
      child: const Icon(Icons.person_rounded, size: 40, color: Color(0xFF356B9C)),
    );

    return _Card(
      radius: 20,
      padding: const EdgeInsets.fromLTRB(15, 15, 15, 8),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  width: 80,
                  height: 86,
                  child: doctor.photoAsset == null
                      ? placeholder
                      : Image.asset(
                          doctor.photoAsset!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => placeholder,
                        ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 2),
                    _text(doctor.name, 18, FontWeight.w700, _C.ink, 25),
                    const SizedBox(height: 7),
                    _text(doctor.specialty, 14, FontWeight.w500, _C.slate600, 22),
                    const SizedBox(height: 0),
                    InkWell(
                      onTap: onSeeReviews,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          children: [
                            _text('★', 17, FontWeight.w700, _C.amber, 24),
                            const SizedBox(width: 4),
                            _text(
                              '${doctor.rating} · ${doctor.reviewCount} avaliações',
                              12,
                              FontWeight.w600,
                              _C.navy,
                              22,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: onSeeProfile,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: _text('Ver perfil', 13, FontWeight.w500, _C.blue, 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.acceptsInsurance, this.onPressed});

  final bool acceptsInsurance;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _C.border)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (acceptsInsurance) ...[
            _text('Aceita seu convênio', 13, FontWeight.w700, _C.green, 20),
            const SizedBox(height: 7),
          ],
          Material(
            borderRadius: BorderRadius.circular(15),
            clipBehavior: Clip.antiAlias,
            child: Ink(
              height: 50,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFFFFD500), Color(0xFFFDC500)]),
              ),
              child: InkWell(
                onTap: onPressed,
                child: Center(
                  child: Text(
                    'Agendar consulta',
                    style: GoogleFonts.manrope(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      height: 24 / 15,
                      color: const Color(0xFF0F1B4D),
                    ),
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