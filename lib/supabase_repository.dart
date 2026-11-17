import 'confirm_agendamento.dart';
import 'specialty_screen.dart';
import 'supabase_client.dart';

Future<Map<String, dynamic>?> loadCurrentProfile() async {
  final user = supabase.auth.currentUser;
  if (user == null) return null;

  final profile = await supabase
      .from('perfis')
      .select('id,nome,email,telefone,data_nascimento,cpf,sexo,tipo')
      .eq('id', user.id)
      .maybeSingle();
  return profile;
}

Future<List<String>> loadAvailableSpecialties() async {
  final rows = await supabase
      .from('consultas')
      .select('especialidade')
      .eq('status', 'disponivel')
      .gte('data_hora', DateTime.now().toUtc().toIso8601String())
      .order('especialidade')
      .limit(5000);
  return rows.map((row) => row['especialidade'] as String).toSet().toList();
}

Future<List<AppointmentRecord>> loadUpcomingAppointments() async {
  final user = supabase.auth.currentUser;
  if (user == null) return const [];

  final rows = await supabase
      .from('consultas')
      .select(
        'id,especialidade,data_hora,preco,tipo_atendimento,'
        'clinicas(nome,endereco,cidade),medicos(nome)',
      )
      .eq('paciente_id', user.id)
      .eq('status', 'agendada')
      .gte('data_hora', DateTime.now().toUtc().toIso8601String())
      .order('data_hora');

  return rows.map((row) => AppointmentRecord.fromMap(row)).toList();
}

Future<List<Map<String, dynamic>>> loadFavorites() async {
  final user = supabase.auth.currentUser;
  if (user == null) return const [];

  final rows = await supabase
      .from('favoritos')
      .select(
        'id,medico_id,exame_id,'
        'medicos(nome,especialidade,clinicas(nome,cidade)),'
        'exames(nome,descricao,clinicas(nome,cidade))',
      )
      .eq('paciente_id', user.id)
      .order('criado_em', ascending: false);
  return rows.map((row) => Map<String, dynamic>.from(row)).toList();
}

Future<List<Map<String, dynamic>>> loadNotifications() async {
  final user = supabase.auth.currentUser;
  if (user == null) return const [];

  final rows = await supabase
      .from('notificacoes')
      .select('id,titulo,mensagem,tipo,lida,criada_em')
      .eq('paciente_id', user.id)
      .order('criada_em', ascending: false);
  return rows.map((row) => Map<String, dynamic>.from(row)).toList();
}

Future<List<Map<String, dynamic>>> loadDoctorReviews(String doctorId) async {
  final rows = await supabase
      .from('avaliacoes')
      .select('nota,comentario,criada_em')
      .eq('medico_id', doctorId)
      .order('criada_em', ascending: false);
  return rows.map((row) => Map<String, dynamic>.from(row)).toList();
}

Future<SpecialtyAvailability> loadSpecialtyAvailability(
  String specialty,
) async {
  final rows = await supabase
      .from('consultas')
      .select(
        'id,medico_id,clinica_id,especialidade,data_hora,preco,'
        'medicos(nome),clinicas(nome,endereco,cidade)',
      )
      .eq('status', 'disponivel')
      .gte('data_hora', DateTime.now().toUtc().toIso8601String())
      .order('data_hora')
      .limit(5000);
  final reviews = await supabase.from('avaliacoes').select('medico_id,nota');
  final ratings = <String, List<int>>{};
  for (final review in reviews) {
    ratings
        .putIfAbsent(review['medico_id'] as String, () => [])
        .add((review['nota'] as num).toInt());
  }

  final normalized = _normalizeDbText(specialty);
  final matching = rows.where((row) {
    final actual = _normalizeDbText(row['especialidade'] as String? ?? '');
    return actual.contains(normalized) ||
        normalized.contains(actual) ||
        _specialtyAlias(normalized, actual);
  });
  final grouped = <String, _SpecialtyBuilder>{};
  DateTime? firstDay;
  for (final row in matching) {
    final doctorId = row['medico_id'] as String;
    final clinicId = row['clinica_id'] as String;
    final doctor = _nested(row['medicos']);
    final clinic = _nested(row['clinicas']);
    final date = DateTime.parse(row['data_hora'] as String).toLocal();
    firstDay ??= DateTime(date.year, date.month, date.day);
    final key = '$doctorId|$clinicId';
    final builder = grouped.putIfAbsent(
      key,
      () => _SpecialtyBuilder(
        doctorId: doctorId,
        name: doctor?['nome'] as String? ?? 'Profissional',
        specialty: row['especialidade'] as String? ?? specialty,
        clinicName: clinic?['nome'] as String? ?? 'Clínica',
        clinicAddress: [
          clinic?['endereco'],
          clinic?['cidade'],
        ].whereType<String>().where((part) => part.isNotEmpty).join(' · '),
        price: _formatPrice(row['preco']),
        ratings: ratings[doctorId] ?? const [],
      ),
    );
    final dateKey = _dateKey(date);
    builder.slotsByDate
        .putIfAbsent(dateKey, () => [])
        .add(
          SpecialtySlot(
            id: row['id'] as String,
            time: _time(date),
            dateTime: date,
          ),
        );
  }

  return SpecialtyAvailability(
    firstDay: firstDay ?? DateTime.now(),
    professionals: grouped.values.map((entry) => entry.build()).toList(),
  );
}

class AppointmentRecord {
  const AppointmentRecord({
    required this.id,
    required this.summary,
    required this.dateTime,
  });

  final String id;
  final AppointmentSummary summary;
  final DateTime dateTime;

  factory AppointmentRecord.fromMap(Map<String, dynamic> row) {
    final dateTime = DateTime.parse(row['data_hora'] as String).toLocal();
    final clinic = _nested(row['clinicas']);
    final doctor = _nested(row['medicos']);
    final address = [
      clinic?['endereco'],
      clinic?['cidade'],
    ].whereType<String>().where((part) => part.isNotEmpty).join(' · ');
    final mode = switch (row['tipo_atendimento']) {
      'convenio' => 'Convênio',
      'particular' => 'Particular',
      _ => 'Atendimento',
    };

    return AppointmentRecord(
      id: row['id'] as String,
      dateTime: dateTime,
      summary: AppointmentSummary(
        consultationId: row['id'] as String,
        doctorName: doctor?['nome'] as String? ?? 'Profissional',
        specialtyAndMode: '${row['especialidade'] as String? ?? ''} · $mode',
        dateLabel: _formatDate(dateTime),
        timeLabel: _formatTime(dateTime),
        clinicName: clinic?['nome'] as String? ?? 'Clínica',
        clinicAddress: address.isEmpty ? 'Endereço não informado' : address,
        price: _formatPrice(row['preco']),
        scheduledAt: dateTime,
      ),
    );
  }
}

class SpecialtyAvailability {
  const SpecialtyAvailability({
    required this.firstDay,
    required this.professionals,
  });

  final DateTime firstDay;
  final List<SpecialtyProfessional> professionals;
}

class _SpecialtyBuilder {
  _SpecialtyBuilder({
    required this.doctorId,
    required this.name,
    required this.specialty,
    required this.clinicName,
    required this.clinicAddress,
    required this.price,
    required this.ratings,
  });

  final String doctorId;
  final String name;
  final String specialty;
  final String clinicName;
  final String clinicAddress;
  final String price;
  final List<int> ratings;
  final Map<String, List<SpecialtySlot>> slotsByDate = {};

  SpecialtyProfessional build() {
    final average = ratings.isEmpty
        ? null
        : ratings.reduce((a, b) => a + b) / ratings.length;
    return SpecialtyProfessional(
      doctorId: doctorId,
      name: name,
      specialty: specialty,
      clinicName: clinicName,
      clinicAddress: clinicAddress,
      price: price,
      rating: average?.toStringAsFixed(1) ?? '—',
      reviewCount: ratings.length,
      slotsByDate: slotsByDate,
    );
  }
}

Map<String, dynamic>? _nested(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  if (value is List && value.isNotEmpty && value.first is Map) {
    return Map<String, dynamic>.from(value.first as Map);
  }
  return null;
}

bool _specialtyAlias(String query, String actual) {
  const aliases = {
    'cardiologia': 'cardiologista',
    'dermatologia': 'dermatologista',
    'ginecologia': 'ginecologista',
    'ortopedia': 'ortopedista',
    'pediatria': 'pediatra',
    'psiquiatria': 'psiquiatra',
    'oftalmologia': 'oftalmologista',
    'otorrino': 'otorrinolaringologista',
    'ginecologia e obstetricia': 'ginecologista',
  };
  final alias = aliases[query];
  return alias != null && actual.contains(alias);
}

String _normalizeDbText(String value) => value
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

String _dateKey(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

String _time(DateTime date) =>
    '${date.hour.toString().padLeft(2, '0')}:'
    '${date.minute.toString().padLeft(2, '0')}';

String _formatDate(DateTime date) {
  const weekdays = [
    'segunda-feira',
    'terça-feira',
    'quarta-feira',
    'quinta-feira',
    'sexta-feira',
    'sábado',
    'domingo',
  ];
  const months = [
    'janeiro',
    'fevereiro',
    'março',
    'abril',
    'maio',
    'junho',
    'julho',
    'agosto',
    'setembro',
    'outubro',
    'novembro',
    'dezembro',
  ];
  return '${weekdays[date.weekday - 1]}, ${date.day} de ${months[date.month - 1]}';
}

String _formatTime(DateTime date) =>
    'às ${date.hour.toString().padLeft(2, '0')}h'
    '${date.minute.toString().padLeft(2, '0')}';

String _formatPrice(dynamic price) {
  if (price == null) return 'Consulte o valor';
  return 'R\$ ${(price as num).toStringAsFixed(2).replaceAll('.', ',')}';
}
