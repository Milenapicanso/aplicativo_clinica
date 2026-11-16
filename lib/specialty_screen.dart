// Tela "Especialidade · Cardiologia" do AppAgendamento (Figma node 114:2).
//
// Serve para qualquer especialidade: troque [title], [subtitle] e [professionals].
// Fontes: Outfit e Manrope (google_fonts).
//
// Fotos (exporte do Figma para assets/images/ e declare a pasta no pubspec.yaml).
// No Figma as duas fotos são recortes de uma mesma imagem, então exporte
// cada rosto separado:
//   assets/images/dra_camila_ribeiro.png
//   assets/images/dr_rafael_lima.png

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class _C {
  static const ink = Color(0xFF19354B);
  static const muted = Color(0xFF52677D);
  static const blue = Color(0xFF261CC1);
  static const border = Color(0xFFE5EBF4);
  static const chipBorder = Color(0xFFD5DFF1);
  static const area = Color(0xFFF3F6FC);
}

class SpecialtyProfessional {
  const SpecialtyProfessional({
    required this.name,
    required this.price,
    required this.rating,
    required this.reviewCount,
    required this.times,
    this.photoAsset,
  });

  final String name;
  final String price; // "R$ 250"
  final String rating; // "4,9"
  final int reviewCount;
  final List<String> times; // ["08:00", "09:00", "11:00"]
  final String? photoAsset;
}

const _sampleProfessionals = [
  SpecialtyProfessional(
    name: 'Dra. Camila Ribeiro',
    price: 'R\$ 250',
    rating: '4,9',
    reviewCount: 128,
    times: ['08:00', '09:00', '11:00'],
    photoAsset: 'assets/images/dra_camila_ribeiro.png',
  ),
  SpecialtyProfessional(
    name: 'Dr. Rafael Lima',
    price: 'R\$ 280',
    rating: '4,8',
    reviewCount: 96,
    times: ['09:30', '10:00', '14:30'],
    photoAsset: 'assets/images/dr_rafael_lima.png',
  ),
];

class SpecialtyScreen extends StatefulWidget {
  SpecialtyScreen({
    super.key,
    this.title = 'Cardiologia',
    this.subtitle = 'Encontre o cuidado para o seu coração',
    this.professionals = _sampleProfessionals,
    DateTime? firstDay,
    this.onBack,
    this.onFilters,
    this.onQueryChanged,
    this.onTimeSelected,
  }) : firstDay = firstDay ?? DateTime(2026, 11, 16);

  final String title;
  final String subtitle;
  final List<SpecialtyProfessional> professionals;

  /// Primeiro dos 6 dias mostrados na faixa de datas.
  final DateTime firstDay;

  final VoidCallback? onBack;
  final VoidCallback? onFilters;
  final ValueChanged<String>? onQueryChanged;

  /// Chamado quando a pessoa escolhe um horário de um profissional.
  final void Function(SpecialtyProfessional professional, DateTime day, String time)?
      onTimeSelected;

  @override
  State<SpecialtyScreen> createState() => _SpecialtyScreenState();
}

class _SpecialtyScreenState extends State<SpecialtyScreen> {
  static const _weekdays = ['SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SÁB', 'DOM'];
  static const _months = [
    'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
    'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
  ];

  bool _online = true; // no Figma "Online" está selecionado
  int _selectedDay = 0;
  final Map<String, String> _selectedTime = {};

  late final List<DateTime> _days = [
    for (var i = 0; i < 6; i++) widget.firstDay.add(Duration(days: i)),
  ];

  @override
  void initState() {
    super.initState();
    // No Figma o primeiro horário do primeiro profissional já vem marcado.
    if (widget.professionals.isNotEmpty && widget.professionals.first.times.isNotEmpty) {
      _selectedTime[widget.professionals.first.name] = widget.professionals.first.times.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = _days[_selectedDay];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _Header(title: widget.title, subtitle: widget.subtitle, onBack: widget.onBack),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 9, 24, 0),
              child: _ModeToggle(
                online: _online,
                onChanged: (value) => setState(() => _online = value),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 15, 24, 12),
              child: Row(
                children: [
                  Expanded(child: _SearchBox(onChanged: widget.onQueryChanged)),
                  const SizedBox(width: 12),
                  _FilterButton(onTap: widget.onFilters),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                color: _C.area,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 19, 24, 12),
                  children: [
                    Text(
                      'Selecione a data da consulta',
                      style: GoogleFonts.manrope(fontSize: 12, height: 1.45, color: _C.muted),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _months[selected.month - 1],
                          style: GoogleFonts.outfit(
                            fontSize: 21,
                            fontWeight: FontWeight.w600,
                            height: 1.45,
                            color: _C.ink,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            '${selected.year}',
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              height: 1.45,
                              color: _C.muted,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        for (var i = 0; i < _days.length; i++)
                          _DayChip(
                            weekday: _weekdays[_days[i].weekday - 1],
                            day: _days[i].day,
                            selected: i == _selectedDay,
                            onTap: () => setState(() => _selectedDay = i),
                          ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Profissionais',
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            height: 1.45,
                            color: _C.ink,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            '${widget.professionals.length} disponíveis',
                            style: GoogleFonts.manrope(fontSize: 12, height: 1.45, color: _C.muted),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    for (final professional in widget.professionals)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ProfessionalCard(
                          professional: professional,
                          selectedTime: _selectedTime[professional.name],
                          onTimeTap: (time) {
                            setState(() => _selectedTime[professional.name] = time);
                            widget.onTimeSelected?.call(professional, selected, time);
                          },
                        ),
                      ),
                    Text(
                      'Valores e horários ilustrativos.',
                      style: GoogleFonts.manrope(fontSize: 10, height: 1.45, color: _C.muted),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.subtitle, this.onBack});

  final String title;
  final String subtitle;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 17, 24, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Material(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: _C.border),
            ),
            child: InkWell(
              onTap: onBack,
              borderRadius: BorderRadius.circular(12),
              child: const SizedBox(
                width: 40,
                height: 40,
                child: Icon(Icons.chevron_left_rounded, size: 22, color: _C.ink),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    height: 1.45,
                    color: _C.ink,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.manrope(fontSize: 12, height: 1.45, color: _C.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.online, required this.onChanged});

  final bool online;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget segment(String label, bool value) {
      final active = online == value;
      return Expanded(
        child: GestureDetector(
          onTap: () => onChanged(value),
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: active ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: active ? Border.all(color: _C.chipBorder) : null,
            ),
            child: Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                height: 1.45,
                color: active ? _C.blue : _C.muted,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      height: 44,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFEDF2FB),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(children: [segment('Presencial', false), segment('Online', true)]),
    );
  }
}

class _SearchBox extends StatelessWidget {
  const _SearchBox({this.onChanged});

  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: _C.area,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, size: 22, color: _C.ink),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              cursorColor: _C.blue,
              style: GoogleFonts.manrope(fontSize: 13, color: _C.ink),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintText: 'Buscar profissional',
                hintStyle: GoogleFonts.manrope(fontSize: 13, height: 1.45, color: _C.muted),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: _C.chipBorder),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: const SizedBox(
          width: 48,
          height: 48,
          child: Icon(Icons.filter_alt_outlined, size: 24, color: _C.ink),
        ),
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.weekday,
    required this.day,
    required this.selected,
    required this.onTap,
  });

  final String weekday;
  final int day;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 54,
        height: 64,
        decoration: BoxDecoration(
          color: selected ? _C.blue : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: selected ? null : Border.all(color: _C.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              weekday,
              style: GoogleFonts.manrope(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : _C.muted,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$day',
              style: GoogleFonts.manrope(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : _C.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfessionalCard extends StatelessWidget {
  const _ProfessionalCard({
    required this.professional,
    required this.selectedTime,
    required this.onTimeTap,
  });

  final SpecialtyProfessional professional;
  final String? selectedTime;
  final ValueChanged<String> onTimeTap;

  @override
  Widget build(BuildContext context) {
    final photoPlaceholder = Container(
      color: const Color(0xFFE5EEF9),
      alignment: Alignment.center,
      child: const Icon(Icons.person_rounded, size: 28, color: Color(0xFF356B9C)),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 50,
                  height: 52,
                  child: professional.photoAsset == null
                      ? photoPlaceholder
                      : Image.asset(
                          professional.photoAsset!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => photoPlaceholder,
                        ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            professional.name,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              height: 1.45,
                              color: _C.ink,
                            ),
                          ),
                        ),
                        Text(
                          professional.price,
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            height: 1.45,
                            color: _C.ink,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          professional.rating,
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            height: 1.45,
                            color: _C.ink,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '★★★★★',
                          style: GoogleFonts.manrope(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            height: 1.45,
                            color: const Color(0xFFA37000),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${professional.reviewCount} avaliações',
                          style: GoogleFonts.manrope(fontSize: 10, height: 1.45, color: _C.muted),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Próximos horários',
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.45,
              color: _C.ink,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (var i = 0; i < professional.times.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _TimeChip(
                    time: professional.times[i],
                    selected: selectedTime == professional.times[i],
                    onTap: () => onTimeTap(professional.times[i]),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({required this.time, required this.selected, required this.onTap});

  final String time;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 31,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEDF2FF) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? const Color(0xFFBBC8F5) : _C.chipBorder),
        ),
        child: Text(
          time,
          style: GoogleFonts.manrope(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: selected ? _C.blue : _C.muted,
          ),
        ),
      ),
    );
  }
}
