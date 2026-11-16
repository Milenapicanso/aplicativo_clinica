// Telas "Confirmar consulta · Convênio" (Figma node 75:282) e
// "Confirmar consulta · Particular e dependente" (Figma node 80:50).
//
// As duas telas do Figma são a mesma tela em estados diferentes, então aqui
// é uma só: "Para você / Para outra pessoa" e "Convênio / Particular" trocam
// o conteúdo, como no design.
//
// Fonte: Manrope (google_fonts).
// Foto: assets/images/dra_camila_ribeiro.png (exporte do Figma; sem o arquivo
// aparece um ícone no lugar).

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class _C {
  static const background = Color(0xFFEDF2FB);
  static const ink = Color(0xFF111827);
  static const navy = Color(0xFF162E93);
  static const blue = Color(0xFF261CC1);
  static const slate700 = Color(0xFF334155);
  static const slate600 = Color(0xFF475569);
  static const slate500 = Color(0xFF64748B);
  static const border = Color(0xFFDCE3EF);
  static const segmentBackground = Color(0xFFEBEFF7);
  static const segmentText = Color(0xFF586579);
  static const highlight = Color(0xFFEDF2FC);
  static const notice = Color(0xFFF0F4FC);
}

class AppointmentSummary {
  const AppointmentSummary({
    required this.doctorName,
    required this.specialtyAndMode,
    required this.dateLabel,
    required this.timeLabel,
    required this.clinicName,
    required this.clinicAddress,
    required this.price,
    this.photoAsset,
  });

  final String doctorName;
  final String specialtyAndMode; // "Cardiologista · Presencial"
  final String dateLabel; // "Sábado, 14 de novembro"
  final String timeLabel; // "às 15h30"
  final String clinicName;
  final String clinicAddress;
  final String price; // "R$ 320"
  final String? photoAsset;

  static const sample = AppointmentSummary(
    doctorName: 'Dra. Camila Ribeiro',
    specialtyAndMode: 'Cardiologista · Presencial',
    dateLabel: 'Sábado, 14 de novembro',
    timeLabel: 'às 15h30',
    clinicName: 'Clínica Coração & Vida',
    clinicAddress: 'Rua do Cuidado, 120 · Bela Vista, São Paulo',
    price: 'R\$ 320',
    photoAsset: 'assets/images/dra_camila_ribeiro.png',
  );
}

/// Pessoa para quem a consulta é marcada.
class PatientOption {
  const PatientOption({required this.name, required this.relation});

  final String name;
  final String relation; // "Titular · Você", "Filho · 8 anos"
}

enum Coverage { insurance, private }

enum PaymentMethod { pix, card, cash }

/// Dados que a tela devolve ao tocar em "Confirmar".
class AppointmentConfirmation {
  const AppointmentConfirmation({
    required this.patient,
    required this.forSelf,
    required this.coverage,
    this.insurancePlan,
    this.insuranceCardNumber,
    this.paymentMethod,
  });

  final PatientOption patient;
  final bool forSelf;
  final Coverage coverage;
  final String? insurancePlan; // só no convênio
  final String? insuranceCardNumber; // só no convênio
  final PaymentMethod? paymentMethod; // só no particular
}

class ConfirmAppointmentScreen extends StatefulWidget {
  const ConfirmAppointmentScreen({
    super.key,
    this.appointment = AppointmentSummary.sample,
    this.holder = const PatientOption(name: 'Maria', relation: 'Titular · Você'),
    this.dependents = const [PatientOption(name: 'Pedro', relation: 'Filho · 8 anos')],
    this.insurancePlans = const ['Unimed · Nacional'],
    this.initialCardNumber = '0000 1234 5678 90',
    this.onBack,
    this.onChangeDateTime,
    this.onConfirm,
  });

  final AppointmentSummary appointment;
  final PatientOption holder;
  final List<PatientOption> dependents;
  final List<String> insurancePlans;
  final String initialCardNumber;

  final VoidCallback? onBack;

  /// Toque em "Alterar" (volta para escolher outro dia/horário).
  final VoidCallback? onChangeDateTime;

  final ValueChanged<AppointmentConfirmation>? onConfirm;

  @override
  State<ConfirmAppointmentScreen> createState() => _ConfirmAppointmentScreenState();
}

class _ConfirmAppointmentScreenState extends State<ConfirmAppointmentScreen> {
  bool _forSelf = true;
  Coverage _coverage = Coverage.insurance;
  PaymentMethod _payment = PaymentMethod.pix;
  late PatientOption? _dependent =
      widget.dependents.isEmpty ? null : widget.dependents.first;
  late String _plan = widget.insurancePlans.first;
  late final TextEditingController _card =
      TextEditingController(text: widget.initialCardNumber);

  @override
  void dispose() {
    _card.dispose();
    super.dispose();
  }

  void _confirm() {
    widget.onConfirm?.call(
      AppointmentConfirmation(
        patient: _forSelf ? widget.holder : (_dependent ?? widget.holder),
        forSelf: _forSelf || _dependent == null,
        coverage: _coverage,
        insurancePlan: _coverage == Coverage.insurance ? _plan : null,
        insuranceCardNumber: _coverage == Coverage.insurance ? _card.text.trim() : null,
        paymentMethod: _coverage == Coverage.private ? _payment : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.appointment;
    final patient = _forSelf ? widget.holder : (_dependent ?? widget.holder);

    return Scaffold(
      backgroundColor: _C.background,
      body: SafeArea(
        child: Column(
          children: [
            // Cabeçalho
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 6, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: widget.onBack,
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 4, 14, 4),
                          child: Text(
                            '‹',
                            style: GoogleFonts.manrope(
                              fontSize: 30,
                              fontWeight: FontWeight.w500,
                              height: 38 / 30,
                              color: _C.navy,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        'Confirmar consulta',
                        style: GoogleFonts.manrope(
                          fontSize: 23,
                          fontWeight: FontWeight.w700,
                          height: 32 / 23,
                          color: _C.ink,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Revise os dados antes de confirmar.',
                    style: GoogleFonts.manrope(fontSize: 12, height: 20 / 12, color: _C.slate500),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 6, 24, 16),
                children: [
                  _sectionTitle('Resumo da consulta'),
                  const SizedBox(height: 10),
                  _SummaryCard(
                    appointment: a,
                    onChangeDateTime: widget.onChangeDateTime,
                  ),
                  const SizedBox(height: 22),
                  _sectionTitle('Para quem é a consulta?'),
                  const SizedBox(height: 10),
                  _Segmented<bool>(
                    options: const [(true, 'Para você'), (false, 'Para outra pessoa')],
                    value: _forSelf,
                    onChanged: (value) => setState(() => _forSelf = value),
                  ),
                  const SizedBox(height: 8),
                  _PatientBox(
                    patient: patient,
                    options: _forSelf ? const [] : widget.dependents,
                    onSelected: (p) => setState(() => _dependent = p),
                  ),
                  const SizedBox(height: 20),
                  _sectionTitle('Como será o atendimento?'),
                  const SizedBox(height: 8),
                  _Segmented<Coverage>(
                    options: const [
                      (Coverage.insurance, 'Convênio'),
                      (Coverage.private, 'Particular'),
                    ],
                    value: _coverage,
                    onChanged: (value) => setState(() => _coverage = value),
                  ),
                  const SizedBox(height: 13),
                  if (_coverage == Coverage.insurance)
                    _insuranceFields()
                  else
                    _privateFields(a.price),
                  const SizedBox(height: 18),
                  Container(
                    height: 29,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _C.notice,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Cancelamento gratuito até 24h antes',
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: _C.slate600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Rodapé fixo
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE4E9F2))),
              ),
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 14),
              child: Material(
                color: const Color(0xFFFFD54A),
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  onTap: _confirm,
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    height: 48,
                    child: Center(
                      child: Text(
                        'Confirmar',
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _insuranceFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Plano de saúde'),
        const SizedBox(height: 7),
        Container(
          height: 44,
          padding: const EdgeInsets.only(left: 13, right: 10),
          decoration: _boxDecoration(),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _plan,
              isExpanded: true,
              borderRadius: BorderRadius.circular(12),
              dropdownColor: Colors.white,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 22, color: _C.navy),
              style: GoogleFonts.manrope(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: _C.slate700,
              ),
              items: [
                for (final plan in widget.insurancePlans)
                  DropdownMenuItem(value: plan, child: Text(plan)),
              ],
              onChanged: (value) => setState(() => _plan = value ?? _plan),
            ),
          ),
        ),
        const SizedBox(height: 14),
        _fieldLabel('Número da carteirinha'),
        const SizedBox(height: 4),
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 13),
          alignment: Alignment.centerLeft,
          decoration: _boxDecoration(),
          child: TextField(
            controller: _card,
            keyboardType: TextInputType.number,
            cursorColor: _C.blue,
            style: GoogleFonts.manrope(fontSize: 13, color: _C.slate700),
            decoration: const InputDecoration(
              isDense: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }

  Widget _privateFields(String price) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Valor da consulta'),
        const SizedBox(height: 5),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              price,
              style: GoogleFonts.manrope(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                height: 32 / 24,
                color: _C.ink,
              ),
            ),
            const Spacer(),
            Container(
              height: 28,
              width: 210,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _C.highlight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Pagamento presencial',
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _C.navy,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _Segmented<PaymentMethod>(
          options: const [
            (PaymentMethod.pix, 'Pix'),
            (PaymentMethod.card, 'Cartão'),
            (PaymentMethod.cash, 'Dinheiro'),
          ],
          value: _payment,
          onChanged: (value) => setState(() => _payment = value),
        ),
        const SizedBox(height: 14),
        Text(
          'Pague na clínica, no dia da consulta.',
          style: GoogleFonts.manrope(fontSize: 11, height: 18 / 11, color: _C.slate500),
        ),
      ],
    );
  }

  Widget _sectionTitle(String text) => Text(
        text,
        style: GoogleFonts.manrope(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          height: 24 / 16,
          color: _C.ink,
        ),
      );

  Widget _fieldLabel(String text) => Text(
        text,
        style: GoogleFonts.manrope(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          height: 18 / 11,
          color: _C.slate600,
        ),
      );

  BoxDecoration _boxDecoration() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _C.border),
      );
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.appointment, this.onChangeDateTime});

  final AppointmentSummary appointment;
  final VoidCallback? onChangeDateTime;

  @override
  Widget build(BuildContext context) {
    final a = appointment;
    final placeholder = Container(
      color: const Color(0xFFE5EEF9),
      alignment: Alignment.center,
      child: const Icon(Icons.person_rounded, size: 30, color: Color(0xFF356B9C)),
    );

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: 56,
                  height: 58,
                  child: a.photoAsset == null
                      ? placeholder
                      : Image.asset(
                          a.photoAsset!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => placeholder,
                        ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      a.doctorName,
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        height: 24 / 16,
                        color: _C.ink,
                      ),
                    ),
                    Text(
                      a.specialtyAndMode,
                      style: GoogleFonts.manrope(fontSize: 12, height: 20 / 12, color: _C.slate500),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
            decoration: BoxDecoration(
              color: _C.highlight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        a.dateLabel,
                        style: GoogleFonts.manrope(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          height: 21 / 13,
                          color: _C.navy,
                        ),
                      ),
                      Text(
                        a.timeLabel,
                        style: GoogleFonts.manrope(
                          fontSize: 21,
                          fontWeight: FontWeight.w700,
                          height: 27 / 21,
                          color: _C.navy,
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: onChangeDateTime,
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Text(
                      'Alterar',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        height: 20 / 12,
                        color: _C.blue,
                        decoration: TextDecoration.underline,
                        decorationColor: _C.blue,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            a.clinicName,
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 20 / 12,
              color: _C.slate700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            a.clinicAddress,
            style: GoogleFonts.manrope(fontSize: 11, height: 18 / 11, color: _C.slate500),
          ),
        ],
      ),
    );
  }
}

/// Seletor de opções no estilo do Figma (fundo cinza, opção ativa em azul).
class _Segmented<T> extends StatelessWidget {
  const _Segmented({
    required this.options,
    required this.value,
    required this.onChanged,
  });

  final List<(T, String)> options;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _C.segmentBackground,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          for (final option in options)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(option.$1),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: option.$1 == value ? _C.navy : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    option.$2,
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      height: 20 / 12,
                      color: option.$1 == value ? Colors.white : _C.segmentText,
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

class _PatientBox extends StatelessWidget {
  const _PatientBox({
    required this.patient,
    required this.options,
    required this.onSelected,
  });

  final PatientOption patient;

  /// Lista para escolher; com 0 ou 1 item o campo é só informativo.
  final List<PatientOption> options;
  final ValueChanged<PatientOption> onSelected;

  @override
  Widget build(BuildContext context) {
    final box = Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _C.border),
      ),
      child: Row(
        children: [
          Text(
            patient.name,
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _C.slate700,
            ),
          ),
          const Spacer(),
          Text(
            patient.relation,
            style: GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: _C.slate500,
            ),
          ),
        ],
      ),
    );

    if (options.length < 2) return box;

    return PopupMenuButton<PatientOption>(
      onSelected: onSelected,
      position: PopupMenuPosition.under,
      child: box,
      itemBuilder: (_) => [
        for (final option in options)
          PopupMenuItem(value: option, child: Text('${option.name} · ${option.relation}')),
      ],
    );
  }
}