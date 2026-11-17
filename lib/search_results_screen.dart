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

import 'confirm_agendamento.dart';
import 'supabase_client.dart';

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
    required this.consultationId,
    required this.doctorId,
    required this.doctorCrm,
    required this.clinicId,
    required this.clinicPhone,
    required this.scheduledAt,
    this.photoAsset,
    this.price,
  });

  final String name;
  final String specialty;
  final String rating; // "4,9"
  final int reviewCount;
  final String clinic;
  final String distance; // "Bela Vista · 1,2 km"
  final String mode;
  final String nextSlot; // "Hoje, 15h30"
  final String consultationId;
  final String doctorId;
  final String? doctorCrm;
  final String clinicId;
  final String? clinicPhone;
  final DateTime scheduledAt;
  final String? photoAsset;

  final String? price; // "R$ 220"

  AppointmentSummary toAppointmentSummary() => AppointmentSummary(
    consultationId: consultationId,
    scheduledAt: scheduledAt,
    doctorName: name,
    specialtyAndMode: '$specialty · $mode',
    dateLabel:
        '${scheduledAt.day.toString().padLeft(2, '0')}/'
        '${scheduledAt.month.toString().padLeft(2, '0')}/'
        '${scheduledAt.year}',
    timeLabel:
        'às ${scheduledAt.hour.toString().padLeft(2, '0')}h'
        '${scheduledAt.minute.toString().padLeft(2, '0')}',
    clinicName: clinic,
    clinicAddress: distance,
    price: price ?? 'Consulte o valor',
    photoAsset: photoAsset,
  );
}

enum SearchResultType { available, clinic, doctor, exam, specialty, none }

class ExamAvailability {
  const ExamAvailability({
    required this.id,
    required this.name,
    required this.description,
    required this.clinic,
    required this.distance,
    required this.price,
  });

  final String id;
  final String name;
  final String description;
  final String clinic;
  final String distance;
  final String price;
}

class SearchResponse {
  const SearchResponse({
    required this.type,
    this.professionals = const [],
    this.exams = const [],
  });

  final SearchResultType type;
  final List<ProfessionalResult> professionals;
  final List<ExamAvailability> exams;
}

Future<SearchResponse> searchCatalog(
  String query, {
  bool includeAllAvailable = false,
}) async {
  final normalizedQuery = _normalizeSearchText(query);
  if (normalizedQuery.isEmpty && !includeAllAvailable) {
    return const SearchResponse(type: SearchResultType.none);
  }

  final records = await Future.wait([
    supabase
        .from('clinicas')
        .select('id,nome,endereco,cidade,telefone')
        .limit(2000),
    supabase
        .from('medicos')
        .select('id,clinica_id,nome,especialidade,crm')
        .limit(5000),
    supabase
        .from('consultas')
        .select(
          'id,clinica_id,medico_id,especialidade,data_hora,preco,tipo_atendimento',
        )
        .eq('status', 'disponivel')
        .gte('data_hora', DateTime.now().toUtc().toIso8601String())
        .order('data_hora')
        .limit(5000),
    supabase
        .from('exames')
        .select('id,clinica_id,nome,descricao,preco')
        .limit(5000),
    supabase.from('avaliacoes').select('medico_id,nota').limit(10000),
  ]);
  final clinics = _indexById(records[0]);
  final doctors = _indexById(records[1]);
  final consultations = _asRows(records[2]);
  final exams = _asRows(records[3]);
  final ratings = _averageRatings(records[4]);

  if (includeAllAvailable) {
    return SearchResponse(
      type: SearchResultType.available,
      professionals: _professionalResults(
        consultations,
        clinics,
        doctors,
        ratings,
        includeAllSlots: true,
      ),
    );
  }

  final clinicMatches = clinics.values.where((clinic) {
    return _matchesText(
      [
        clinic['nome'],
        clinic['endereco'],
        clinic['cidade'],
      ].whereType<String>().join(' '),
      normalizedQuery,
    );
  }).toSet();
  if (clinicMatches.isNotEmpty) {
    return SearchResponse(
      type: SearchResultType.clinic,
      professionals: _professionalResults(
        consultations
            .where(
              (row) => clinicMatches.any(
                (clinic) => clinic['id'] == row['clinica_id'],
              ),
            )
            .toList(),
        clinics,
        doctors,
        ratings,
      ),
    );
  }

  final doctorIds = doctors.values
      .where(
        (doctor) =>
            _matchesText(doctor['nome'] as String? ?? '', normalizedQuery),
      )
      .map((doctor) => doctor['id'])
      .toSet();
  if (doctorIds.isNotEmpty) {
    return SearchResponse(
      type: SearchResultType.doctor,
      professionals: _professionalResults(
        consultations
            .where((row) => doctorIds.contains(row['medico_id']))
            .toList(),
        clinics,
        doctors,
        ratings,
      ),
    );
  }

  final examResults = exams
      .where(
        (exam) => _matchesText(
          '${exam['nome'] ?? ''} ${exam['descricao'] ?? ''}',
          normalizedQuery,
        ),
      )
      .toList();
  if (examResults.isNotEmpty) {
    return SearchResponse(
      type: SearchResultType.exam,
      exams: examResults.map((exam) {
        final clinic = clinics[exam['clinica_id']];
        return ExamAvailability(
          id: exam['id'] as String,
          name: exam['nome'] as String,
          description: exam['descricao'] as String? ?? '',
          clinic: clinic?['nome'] as String? ?? 'Clínica',
          distance: [
            clinic?['endereco'],
            clinic?['cidade'],
          ].whereType<String>().where((part) => part.isNotEmpty).join(' · '),
          price: _formatPrice(exam['preco']),
        );
      }).toList(),
    );
  }

  if (const {
    'medico',
    'medicos',
    'profissional',
    'profissionais',
  }.contains(normalizedQuery)) {
    return SearchResponse(
      type: SearchResultType.doctor,
      professionals: _professionalResults(
        consultations,
        clinics,
        doctors,
        ratings,
      ),
    );
  }
  if (const {'exame', 'exames'}.contains(normalizedQuery)) {
    return SearchResponse(
      type: SearchResultType.exam,
      exams: exams.map((exam) {
        final clinic = clinics[exam['clinica_id']];
        return ExamAvailability(
          id: exam['id'] as String,
          name: exam['nome'] as String,
          description: exam['descricao'] as String? ?? '',
          clinic: clinic?['nome'] as String? ?? 'Clínica',
          distance: [
            clinic?['endereco'],
            clinic?['cidade'],
          ].whereType<String>().where((part) => part.isNotEmpty).join(' · '),
          price: _formatPrice(exam['preco']),
        );
      }).toList(),
    );
  }

  final specialtyResults = consultations
      .where(
        (row) => _matchesSpecialty(
          row['especialidade'] as String? ?? '',
          normalizedQuery,
        ),
      )
      .toList();
  if (specialtyResults.isNotEmpty) {
    return SearchResponse(
      type: SearchResultType.specialty,
      professionals: _professionalResults(
        specialtyResults,
        clinics,
        doctors,
        ratings,
      ),
    );
  }

  return const SearchResponse(type: SearchResultType.none);
}

bool _matchesText(String value, String query) =>
    _normalizeSearchText(value).contains(query);

bool _matchesSpecialty(String specialty, String query) {
  final normalized = _normalizeSearchText(specialty);
  if (normalized.contains(query)) return true;
  const aliases = {
    'cardiologista': ['cardiologia', 'cardio'],
    'dermatologista': ['dermatologia'],
    'ginecologista': ['ginecologia', 'obstetricia'],
    'ortopedista': ['ortopedia'],
    'pediatra': ['pediatria'],
    'psiquiatra': ['psiquiatria'],
    'oftalmologista': ['oftalmologia'],
    'otorrinolaringologista': ['otorrino', 'otorrinolaringologia'],
  };
  final terms = aliases[normalized] ?? const [];
  return terms.any((term) => term.contains(query) || query.contains(term));
}

List<Map<String, dynamic>> _asRows(dynamic data) =>
    (data as List).map((row) => Map<String, dynamic>.from(row as Map)).toList();

Map<String, Map<String, dynamic>> _indexById(dynamic data) => {
  for (final row in _asRows(data)) row['id'] as String: row,
};

Map<String, ({double average, int count})> _averageRatings(dynamic data) {
  final grouped = <String, List<int>>{};
  for (final row in _asRows(data)) {
    grouped
        .putIfAbsent(row['medico_id'] as String, () => [])
        .add((row['nota'] as num).toInt());
  }
  return {
    for (final entry in grouped.entries)
      entry.key: (
        average: entry.value.reduce((a, b) => a + b) / entry.value.length,
        count: entry.value.length,
      ),
  };
}

List<ProfessionalResult> _professionalResults(
  List<Map<String, dynamic>> slots,
  Map<String, Map<String, dynamic>> clinics,
  Map<String, Map<String, dynamic>> doctors,
  Map<String, ({double average, int count})> ratings, {
  bool includeAllSlots = false,
}) {
  final seenLocations = <String>{};
  final results = <ProfessionalResult>[];
  for (final slot in slots) {
    final doctorId = slot['medico_id'] as String;
    final locationKey = '$doctorId|${slot['clinica_id']}';
    if (!includeAllSlots && !seenLocations.add(locationKey)) continue;
    final doctor = doctors[doctorId]!;
    final clinic = clinics[slot['clinica_id']];
    final rating = ratings[doctorId];
    final date = DateTime.parse(slot['data_hora'] as String).toLocal();
    results.add(
      ProfessionalResult(
        name: doctor['nome'] as String,
        specialty: _displaySpecialty(slot['especialidade'] as String),
        rating: rating == null ? '—' : rating.average.toStringAsFixed(1),
        reviewCount: rating?.count ?? 0,
        clinic: clinic?['nome'] as String? ?? 'Clínica',
        distance: [
          clinic?['endereco'],
          clinic?['cidade'],
        ].whereType<String>().where((part) => part.isNotEmpty).join(' · '),
        mode: switch (slot['tipo_atendimento']) {
          'convenio' => 'Convênio',
          'particular' => 'Particular',
          _ => 'Disponível',
        },
        nextSlot:
            '${date.day.toString().padLeft(2, '0')}/'
            '${date.month.toString().padLeft(2, '0')} · '
            '${date.hour.toString().padLeft(2, '0')}:'
            '${date.minute.toString().padLeft(2, '0')}',
        consultationId: slot['id'] as String,
        doctorId: doctorId,
        doctorCrm: doctor['crm'] as String?,
        clinicId: slot['clinica_id'] as String,
        clinicPhone: clinic?['telefone'] as String?,
        scheduledAt: date,
        price: _formatPrice(slot['preco']),
      ),
    );
  }
  return results;
}

String _displaySpecialty(String specialty) =>
    _normalizeSearchText(specialty).contains('otorrino')
    ? 'Oftalmologista'
    : specialty;

String _formatPrice(dynamic price) {
  if (price == null) return 'Consulte o valor';
  final value = (price as num).toStringAsFixed(2).replaceAll('.', ',');
  return 'R\$ $value';
}

String _normalizeSearchText(String value) => value
    .toLowerCase()
    .replaceAll(RegExp('[áàâãä]'), 'a')
    .replaceAll(RegExp('[éèêë]'), 'e')
    .replaceAll(RegExp('[íìîï]'), 'i')
    .replaceAll(RegExp('[óòôõö]'), 'o')
    .replaceAll(RegExp('[úùûü]'), 'u')
    .replaceAll('ç', 'c')
    .replaceAll(RegExp(r'[^a-z0-9 ]'), ' ')
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();

enum _AvailableConsultationFilter { all, specialty, clinic }

class SearchResultsScreen extends StatefulWidget {
  const SearchResultsScreen({
    super.key,
    required this.query,
    required this.response,
    this.city = 'São Paulo, SP',
    this.onBack,
    this.onChangeCity,
    this.onChangeQuery,
    this.onSort,
    this.onSeeMore,
    this.onSchedule,
    this.onFavoriteDoctor,
    this.onFavoriteExam,
  });

  final String query;
  final Future<SearchResponse> response;
  final String city;
  final VoidCallback? onBack;
  final VoidCallback? onChangeCity;
  final VoidCallback? onChangeQuery;
  final VoidCallback? onSort;

  /// Toque em "Ver mais" (abre o perfil).
  final ValueChanged<ProfessionalResult>? onSeeMore;

  /// Toque em "Agendar" (vai para a confirmação da consulta).
  final ValueChanged<ProfessionalResult>? onSchedule;
  final ValueChanged<ProfessionalResult>? onFavoriteDoctor;
  final ValueChanged<ExamAvailability>? onFavoriteExam;

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  _AvailableConsultationFilter _filter = _AvailableConsultationFilter.all;
  String? _selectedSpecialty;
  String? _selectedClinic;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SearchResponse>(
      future: widget.response,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            backgroundColor: _C.background,
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            backgroundColor: _C.background,
            body: SafeArea(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: widget.onBack,
                      icon: const Icon(Icons.chevron_left_rounded),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'Erro ao consultar os resultados: ${snapshot.error}',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return _buildResults(context, snapshot.data!);
      },
    );
  }

  Widget _buildResults(BuildContext context, SearchResponse response) {
    final filteredProfessionals = switch (_filter) {
      _AvailableConsultationFilter.all => response.professionals,
      _AvailableConsultationFilter.specialty =>
        _selectedSpecialty == null
            ? response.professionals
            : response.professionals
                  .where((item) => item.specialty == _selectedSpecialty)
                  .toList(),
      _AvailableConsultationFilter.clinic =>
        _selectedClinic == null
            ? response.professionals
            : response.professionals
                  .where((item) => item.clinic == _selectedClinic)
                  .toList(),
    };
    final resultCount = response.type == SearchResultType.exam
        ? response.exams.length
        : filteredProfessionals.length;
    final specialties =
        response.professionals.map((item) => item.specialty).toSet().toList()
          ..sort();
    final clinics =
        response.professionals.map((item) => item.clinic).toSet().toList()
          ..sort();
    final resultLabel = switch (response.type) {
      SearchResultType.available =>
        '$resultCount consulta${resultCount == 1 ? '' : 's'} disponível${resultCount == 1 ? '' : 'is'}',
      SearchResultType.clinic =>
        '$resultCount consultas disponíveis nesta clínica',
      SearchResultType.doctor =>
        '$resultCount locais com horários para este médico',
      SearchResultType.exam => '$resultCount clínicas com este exame',
      SearchResultType.specialty => '$resultCount profissionais com horários',
      SearchResultType.none => 'Nenhum resultado encontrado',
    };

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
                    onTap: widget.onBack,
                    borderRadius: BorderRadius.circular(20),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.chevron_left_rounded,
                        size: 24,
                        color: _C.ink,
                      ),
                    ),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    'Resultados da busca',
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
                  onTap: widget.onChangeCity,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: _C.blue,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.city,
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          height: 22 / 12,
                          color: _C.blue,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 15,
                        color: _C.blue,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 9, 24, 0),
              child: _SearchField(
                initialValue: widget.query,
                onTap: widget.onChangeQuery,
              ),
            ),
            if (response.type != SearchResultType.exam) ...[
              const SizedBox(height: 12),
              _AvailableConsultationFilters(
                selectedFilter: _filter,
                selectedSpecialty: _selectedSpecialty,
                selectedClinic: _selectedClinic,
                specialties: specialties,
                clinics: clinics,
                onFilterChanged: (filter) {
                  setState(() {
                    _filter = filter;
                    _selectedSpecialty = null;
                    _selectedClinic = null;
                  });
                },
                onSpecialtyChanged: (specialty) {
                  setState(() => _selectedSpecialty = specialty);
                },
                onClinicChanged: (clinic) {
                  setState(() => _selectedClinic = clinic);
                },
              ),
            ],
            // Resumo
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      resultLabel,
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 22 / 14,
                        color: _C.ink,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: widget.onSort,
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
            if (resultCount == 0)
              _EmptySearchResult(
                query: widget.query,
                noAvailableConsultations:
                    response.type == SearchResultType.available &&
                    _filter == _AvailableConsultationFilter.all,
              )
            else if (response.type == SearchResultType.exam)
              for (final exam in response.exams)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                  child: _ExamCard(
                    exam: exam,
                    onFavorite: () => widget.onFavoriteExam?.call(exam),
                  ),
                )
            else
              for (final professional in filteredProfessionals)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                  child: _ProfessionalCard(
                    data: professional,
                    onSeeMore: () => widget.onSeeMore?.call(professional),
                    onSchedule: () => widget.onSchedule?.call(professional),
                    onFavorite: () =>
                        widget.onFavoriteDoctor?.call(professional),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _AvailableConsultationFilters extends StatelessWidget {
  const _AvailableConsultationFilters({
    required this.selectedFilter,
    required this.selectedSpecialty,
    required this.selectedClinic,
    required this.specialties,
    required this.clinics,
    required this.onFilterChanged,
    required this.onSpecialtyChanged,
    required this.onClinicChanged,
  });

  final _AvailableConsultationFilter selectedFilter;
  final String? selectedSpecialty;
  final String? selectedClinic;
  final List<String> specialties;
  final List<String> clinics;
  final ValueChanged<_AvailableConsultationFilter> onFilterChanged;
  final ValueChanged<String?> onSpecialtyChanged;
  final ValueChanged<String?> onClinicChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _SearchFilterChip(
                  label: 'Todos',
                  selected: selectedFilter == _AvailableConsultationFilter.all,
                  onSelected: () =>
                      onFilterChanged(_AvailableConsultationFilter.all),
                ),
                const SizedBox(width: 8),
                _SearchFilterChip(
                  label: 'Especialistas',
                  selected:
                      selectedFilter == _AvailableConsultationFilter.specialty,
                  onSelected: () =>
                      onFilterChanged(_AvailableConsultationFilter.specialty),
                ),
                const SizedBox(width: 8),
                _SearchFilterChip(
                  label: 'Clínicas',
                  selected:
                      selectedFilter == _AvailableConsultationFilter.clinic,
                  onSelected: () =>
                      onFilterChanged(_AvailableConsultationFilter.clinic),
                ),
              ],
            ),
          ),
          if (selectedFilter == _AvailableConsultationFilter.specialty) ...[
            const SizedBox(height: 8),
            _SearchFilterOptions(
              options: specialties,
              selectedOption: selectedSpecialty,
              onSelected: onSpecialtyChanged,
            ),
          ],
          if (selectedFilter == _AvailableConsultationFilter.clinic) ...[
            const SizedBox(height: 8),
            _SearchFilterOptions(
              options: clinics,
              selectedOption: selectedClinic,
              onSelected: onClinicChanged,
            ),
          ],
        ],
      ),
    );
  }
}

class _SearchFilterOptions extends StatelessWidget {
  const _SearchFilterOptions({
    required this.options,
    required this.selectedOption,
    required this.onSelected,
  });

  final List<String> options;
  final String? selectedOption;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _SearchFilterChip(
            label: 'Todas',
            selected: selectedOption == null,
            onSelected: () => onSelected(null),
          ),
          for (final option in options) ...[
            const SizedBox(width: 8),
            _SearchFilterChip(
              label: option,
              selected: selectedOption == option,
              onSelected: () => onSelected(option),
            ),
          ],
        ],
      ),
    );
  }
}

class _SearchFilterChip extends StatelessWidget {
  const _SearchFilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      onSelected: (value) {
        if (value) onSelected();
      },
      labelStyle: GoogleFonts.manrope(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: selected ? _C.blue : _C.slate600,
      ),
      backgroundColor: Colors.white,
      selectedColor: const Color(0xFFE5EEFF),
      side: BorderSide(color: selected ? _C.blue : _C.border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.initialValue, this.onTap});

  final String initialValue;
  final VoidCallback? onTap;

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
            child: TextFormField(
              initialValue: initialValue,
              readOnly: true,
              onTap: onTap,
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

class _EmptySearchResult extends StatelessWidget {
  const _EmptySearchResult({
    required this.query,
    required this.noAvailableConsultations,
  });

  final String query;
  final bool noAvailableConsultations;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _C.border),
        ),
        child: Column(
          children: [
            const Icon(Icons.search_off_rounded, size: 38, color: _C.slate500),
            const SizedBox(height: 10),
            Text(
              noAvailableConsultations
                  ? 'Não há consultas disponíveis no momento.'
                  : 'Não encontramos resultados para “$query”.',
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _C.ink,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              noAvailableConsultations
                  ? 'Tente novamente mais tarde.'
                  : 'Tente buscar por clínica, médico, exame ou especialidade.',
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(fontSize: 12, color: _C.slate500),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExamCard extends StatelessWidget {
  const _ExamCard({required this.exam, this.onFavorite});

  final ExamAvailability exam;
  final VoidCallback? onFavorite;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xFFE5EEFF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.biotech_outlined,
                  color: _C.blue,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  exam.name,
                  style: GoogleFonts.manrope(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _C.ink,
                  ),
                ),
              ),
              IconButton(
                onPressed: onFavorite,
                icon: const Icon(Icons.favorite_border_rounded, color: _C.blue),
                tooltip: 'Adicionar aos favoritos',
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (exam.description.isNotEmpty) ...[
            Text(
              exam.description,
              style: GoogleFonts.manrope(fontSize: 12, color: _C.slate600),
            ),
            const SizedBox(height: 10),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 17,
                color: _C.slate500,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exam.clinic,
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _C.slate700,
                      ),
                    ),
                    Text(
                      exam.distance,
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        color: _C.slate500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
            decoration: BoxDecoration(
              color: _C.nextSlotBg,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Row(
              children: [
                const Icon(Icons.schedule_rounded, size: 17, color: _C.navy),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    'Valor do exame',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _C.navy,
                    ),
                  ),
                ),
                Text(
                  exam.price,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: _C.ink,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfessionalCard extends StatelessWidget {
  const _ProfessionalCard({
    required this.data,
    this.onSeeMore,
    this.onSchedule,
    this.onFavorite,
  });

  final ProfessionalResult data;
  final VoidCallback? onSeeMore;
  final VoidCallback? onSchedule;
  final VoidCallback? onFavorite;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 15, 15, 13),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.border),
        color: Colors.white,
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
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            data.name,
                            style: GoogleFonts.manrope(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              height: 24 / 16,
                              color: _C.ink,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: onFavorite,
                          icon: const Icon(
                            Icons.favorite_border_rounded,
                            color: _C.blue,
                          ),
                          tooltip: 'Adicionar aos favoritos',
                        ),
                      ],
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
                    Text(
                      data.reviewCount == 0
                          ? 'Ainda sem avaliações'
                          : '★ ${data.rating} · ${data.reviewCount} avaliações',
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        height: 20 / 11,
                        color: _C.slate500,
                      ),
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
                child: Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: _C.slate500,
                ),
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
                        fontWeight: FontWeight.w500,
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
            child: Row(
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                    textStyle: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                      textStyle: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
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
      child: const Icon(
        Icons.person_rounded,
        size: 32,
        color: Color(0xFF356B9C),
      ),
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
                errorBuilder: (_, _, _) => placeholder,
              ),
      ),
    );
  }
}
