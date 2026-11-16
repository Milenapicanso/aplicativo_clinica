// Tela "Resultados da busca" do AppAgendamento (Figma node 68:2).
//
// Fonte: Manrope (google_fonts).
//
// Fotos dos profissionais (exporte do Figma para assets/images/ e declare a
// pasta no pubspec.yaml). Enquanto o arquivo não existir, aparece um ícone:
//   assets/images/dra_camila_ribeiro.png   (Figma "Foto de Dra. Camila Ribeiro")
//   assets/images/dr_rafael_martins.png    (Figma "Foto de Dr. Rafael Martins")

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class _C {
  static const background = Color(0xFFF9FDFF);
  static const ink = Color(0xFF111827);
  static const slate600 = Color(0xFF475569);
  static const slate500 = Color(0xFF64748B);
  static const slate700 = Color(0xFF334155);
  static const blue = Color(0xFF261CC1);
  static const navy = Color(0xFF162E93);
  static const border = Color(0xFFDCE3EF);
  static const yellow = Color(0xB3FFD54A); // rgba(255, 213, 74, 0.7)
  static const green = Color(0xFF23734C);
  static const nextSlotBg = Color(0xFFF0F4FC);
}

/// Dados de um cartão da lista.
class ProfessionalResult {
  const ProfessionalResult({
    required this.name,
    required this.specialty,
    required this.rating,
    required this.reviewCount,
    required this.clinic,
    required this.distance,
    required this.mode,
    required this.nextSlot,
    this.photoAsset,
    this.acceptsInsurance = false,
    this.price,
  });

  final String name;
  final String specialty;
  final String rating; // "4,9"
  final int reviewCount;
  final String clinic;
  final String distance; // "Bela Vista · 1,2 km"
  final String mode; // "Presencial" ou "Online"
  final String nextSlot; // "Hoje, 15h30"
  final String? photoAsset;

  /// Quando verdadeiro, o cartão ganha o degradê azul e mostra
  /// "Aceita seu convênio". Quando falso, mostra o [price].
  final bool acceptsInsurance;
  final String? price; // "R$ 220"
}

const _sampleResults = [
  ProfessionalResult(
    name: 'Dra. Camila Ribeiro',
    specialty: 'Cardiologista',
    rating: '4,9',
    reviewCount: 128,
    clinic: 'Clínica Coração & Vida',
    distance: 'Bela Vista · 1,2 km',
    mode: 'Presencial',
    nextSlot: 'Hoje, 15h30',
    photoAsset: 'assets/images/dra_camila_ribeiro.png',
    acceptsInsurance: true,
  ),
  ProfessionalResult(
    name: 'Dr. Rafael Martins',
    specialty: 'Clínico geral',
    rating: '4,8',
    reviewCount: 96,
    clinic: 'Clínica Saúde Integral',
    distance: 'Vila Mariana · 3,4 km',
    mode: 'Online',
    nextSlot: 'Amanhã, 9h',
    photoAsset: 'assets/images/dr_rafael_martins.png',
    price: 'R\$ 220',
  ),
  ProfessionalResult(
    name: 'Dra. Fabiana Santos',
    specialty: 'Ginecologista',
    rating: '4,9',
    reviewCount: 128,
    clinic: 'Clínica Coração & Vida',
    distance: 'Bela Vista · 1,2 km',
    mode: 'Presencial',
    nextSlot: 'Hoje, 15h30',
    photoAsset: 'assets/images/dra_camila_ribeiro.png', // o Figma reaproveita esta foto
    acceptsInsurance: true,
  ),
];

class SearchResultsScreen extends StatelessWidget {
  const SearchResultsScreen({
    super.key,
    this.results = _sampleResults,
    this.city = 'São Paulo, SP',
    this.onBack,
    this.onChangeCity,
    this.onQueryChanged,
    this.onFilters,
    this.onSort,
    this.onSeeMore,
    this.onSchedule,
  });

  final List<ProfessionalResult> results;
  final String city;
  final VoidCallback? onBack;
  final VoidCallback? onChangeCity;
  final ValueChanged<String>? onQueryChanged;
  final VoidCallback? onFilters;
  final VoidCallback? onSort;

  /// Toque em "Ver mais" (abre o perfil).
  final ValueChanged<ProfessionalResult>? onSeeMore;

  /// Toque em "Agendar" (vai para a confirmação da consulta).
  final ValueChanged<ProfessionalResult>? onSchedule;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            // Título com botão voltar
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
              child: Row(
                children: [
                  InkWell(
                    onTap: onBack,
                    borderRadius: BorderRadius.circular(20),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.chevron_left_rounded, size: 24, color: _C.ink),
                    ),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    'Agendar consulta',
                    style: GoogleFonts.manrope(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      height: 34 / 24,
                      color: _C.ink,
                    ),
                  ),
                ],
              ),
            ),
            // Localização
            Padding(
              padding: const EdgeInsets.fromLTRB(37, 14, 24, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: InkWell(
                  onTap: onChangeCity,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on_outlined, size: 16, color: _C.blue),
                      const SizedBox(width: 6),
                      Text(
                        city,
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          height: 22 / 12,
                          color: _C.blue,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.keyboard_arrow_down_rounded, size: 15, color: _C.blue),
                    ],
                  ),
                ),
              ),
            ),
            // Busca + filtros
            Padding(
              padding: const EdgeInsets.fromLTRB(31, 9, 24, 0),
              child: Row(
                children: [
                  Expanded(child: _SearchField(onChanged: onQueryChanged)),
                  const SizedBox(width: 14),
                  _FiltersButton(onTap: onFilters),
                ],
              ),
            ),
            // Resumo
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 38, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${results.length} profissionais encontrados',
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 22 / 14,
                      color: _C.ink,
                    ),
                  ),
                  InkWell(
                    onTap: onSort,
                    child: Text(
                      'Mais próximos',
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        height: 20 / 11,
                        color: _C.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            for (final professional in results)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: _ProfessionalCard(
                  data: professional,
                  onSeeMore: () => onSeeMore?.call(professional),
                  onSchedule: () => onSchedule?.call(professional),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({this.onChanged});

  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFAAB3C3)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 5),
          Container(
            width: 36,
            height: 34,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFFE5EEFF),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.search_rounded, size: 20, color: _C.blue),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              cursorColor: _C.blue,
              style: GoogleFonts.manrope(fontSize: 12, color: _C.ink),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintText: 'Profissional, especialidade ou clínica',
                hintStyle: GoogleFonts.manrope(
                  fontSize: 12,
                  height: 20 / 12,
                  color: _C.slate500,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _FiltersButton extends StatelessWidget {
  const _FiltersButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _C.yellow,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 50,
          height: 46,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.tune_rounded, size: 16, color: _C.blue),
              Text(
                'Filtros',
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 20 / 12,
                  color: _C.blue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfessionalCard extends StatelessWidget {
  const _ProfessionalCard({
    required this.data,
    this.onSeeMore,
    this.onSchedule,
  });

  final ProfessionalResult data;
  final VoidCallback? onSeeMore;
  final VoidCallback? onSchedule;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 15, 15, 13),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.border),
        color: data.acceptsInsurance ? null : Colors.white,
        gradient: data.acceptsInsurance
            ? const LinearGradient(
                begin: Alignment(-1, -0.03),
                end: Alignment(1, 0.03),
                colors: [Color(0xFFEDF2FB), Color(0xFFD7E3FC)],
                stops: [0.19484, 0.97074],
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Foto + nome + especialidade + avaliação
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Photo(asset: data.photoAsset),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.name,
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        height: 24 / 16,
                        color: _C.ink,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      data.specialty,
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        height: 20 / 13,
                        color: _C.slate600,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFFC21A)),
                        const SizedBox(width: 6),
                        Text(
                          data.rating,
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            height: 20 / 12,
                            color: _C.ink,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '(${data.reviewCount} avaliações)',
                          style: GoogleFonts.manrope(
                            fontSize: 11,
                            height: 20 / 11,
                            color: _C.slate500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Clínica, distância e modalidade
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 3),
                child: Icon(Icons.location_on_outlined, size: 16, color: _C.slate500),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.clinic,
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: data.acceptsInsurance ? FontWeight.w600 : FontWeight.w500,
                        height: 22 / 12,
                        color: _C.slate700,
                      ),
                    ),
                    Text(
                      data.distance,
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        height: 20 / 11,
                        color: _C.slate500,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 23),
                child: Container(
                  width: 82,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _C.yellow,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Text(
                    data.mode,
                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _C.blue,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          // Próximo horário
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 11),
            decoration: BoxDecoration(
              color: _C.nextSlotBg,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Row(
              children: [
                const Icon(Icons.schedule_rounded, size: 18, color: _C.navy),
                const SizedBox(width: 8),
                Text(
                  'Próximo horário',
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: _C.slate600,
                  ),
                ),
                const Spacer(),
                Text(
                  data.nextSlot,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _C.navy,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 7),
          // Convênio ou preço
          SizedBox(
            height: 24,
            child: data.acceptsInsurance
                ? Row(
                    children: [
                      const Icon(Icons.verified_user_outlined, size: 16, color: _C.green),
                      const SizedBox(width: 7),
                      Text(
                        'Aceita seu convênio',
                        style: GoogleFonts.manrope(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _C.green,
                        ),
                      ),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        data.price ?? '',
                        style: GoogleFonts.manrope(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: _C.ink,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'por consulta',
                        style: GoogleFonts.manrope(fontSize: 11, color: _C.slate500),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 7),
          // Botões
          Row(
            children: [
              SizedBox(
                width: 132,
                height: 34,
                child: OutlinedButton(
                  onPressed: onSeeMore,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _C.navy,
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: _C.navy),
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                    textStyle: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  child: const Text('Ver mais'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 34,
                  child: FilledButton(
                    onPressed: onSchedule,
                    style: FilledButton.styleFrom(
                      backgroundColor: _C.navy,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                      textStyle: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    child: const Text('Agendar'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Photo extends StatelessWidget {
  const _Photo({this.asset});

  final String? asset;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      color: const Color(0xFFE5EEF9),
      alignment: Alignment.center,
      child: const Icon(Icons.person_rounded, size: 32, color: Color(0xFF356B9C)),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 60,
        height: 64,
        child: asset == null
            ? placeholder
            : Image.asset(
                asset!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => placeholder,
              ),
      ),
    );
  }
}