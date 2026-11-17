import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestException;

import 'app_colors.dart';
import 'supabase_client.dart';
import 'supabase_repository.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  int _selectedFilter = 0; // 0: Todos, 1: Médicos, 2: Exames
  String _searchQuery = '';
  late Future<List<Map<String, dynamic>>> _favorites;

  @override
  void initState() {
    super.initState();
    _favorites = loadFavorites();
  }

  Future<void> _removeFavorite(String id) async {
    try {
      await supabase.from('favoritos').delete().eq('id', id);
      if (mounted) setState(() => _favorites = loadFavorites());
    } on PostgrestException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _favorites,
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
                'Não foi possível carregar favoritos: ${snapshot.error}',
              ),
            ),
          );
        }
        return _buildFavorites(context, snapshot.data ?? const []);
      },
    );
  }

  Widget _buildFavorites(
    BuildContext context,
    List<Map<String, dynamic>> favorites,
  ) {
    final doctors = favorites
        .where((row) => row['medico_id'] != null)
        .where(
          (row) => _matches(
            _related(row['medicos'])?['nome'] as String? ?? '',
            _searchQuery,
          ),
        )
        .toList();
    final exams = favorites
        .where((row) => row['exame_id'] != null)
        .where(
          (row) => _matches(
            _related(row['exames'])?['nome'] as String? ?? '',
            _searchQuery,
          ),
        )
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 150),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Favoritos',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accentYellow,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${doctors.length + exams.length}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColors.darkNavy,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Seus médicos e exames em um só lugar.',
              style: TextStyle(fontSize: 14, color: AppColors.slateText),
            ),
            const SizedBox(height: 20),

            // Busca
            TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Buscar nos favoritos',
                hintStyle: const TextStyle(
                  color: AppColors.slateText,
                  fontSize: 14,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.slateText,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: AppColors.borderLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: AppColors.primaryBlue),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Filtro Segmentado
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.cardFill,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  _buildSegmentTab(
                    0,
                    'Todos (${doctors.length + exams.length})',
                  ),
                  _buildSegmentTab(1, 'Médicos (${doctors.length})'),
                  _buildSegmentTab(2, 'Exames (${exams.length})'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Seção Médicos
            if (_selectedFilter == 0 || _selectedFilter == 1) ...[
              _buildSectionTitle('Médicos', '${doctors.length}'),
              const SizedBox(height: 12),
              for (final favorite in doctors) ...[
                _buildDoctorCard(favorite),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 24),
            ],

            // Seção Exames
            if (_selectedFilter == 0 || _selectedFilter == 2) ...[
              _buildSectionTitle('Exames', '${exams.length}'),
              const SizedBox(height: 12),
              for (final favorite in exams) ...[
                _buildExamCard(favorite),
                const SizedBox(height: 12),
              ],
            ],
            if ((_selectedFilter == 1 && doctors.isEmpty) ||
                (_selectedFilter == 2 && exams.isEmpty) ||
                (_selectedFilter == 0 && doctors.isEmpty && exams.isEmpty))
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: Text('Nenhum favorito encontrado.')),
              ),
          ],
        ),
      ),
    );
  }

  bool _matches(String value, String query) =>
      query.trim().isEmpty ||
      value.toLowerCase().contains(query.trim().toLowerCase());

  Map<String, dynamic>? _related(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    if (value is List && value.isNotEmpty && value.first is Map) {
      return Map<String, dynamic>.from(value.first as Map);
    }
    return null;
  }

  Widget _buildSegmentTab(int index, String label) {
    final bool isSelected = _selectedFilter == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedFilter = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppColors.darkNavy : AppColors.slateText,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, String count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        Text(
          count,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.slateText,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorCard(Map<String, dynamic> favorite) {
    final doctor = _related(favorite['medicos']);
    final clinic = _related(doctor?['clinicas']);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardFill,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor?['nome'] as String? ?? 'Profissional',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkNavy,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      doctor?['especialidade'] as String? ?? '',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.slateText,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _removeFavorite(favorite['id'] as String),
                icon: const Icon(
                  Icons.favorite,
                  color: AppColors.primaryBlue,
                  size: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  clinic?['nome'] as String? ?? '',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.slateText,
                  ),
                ),
              ),
              SizedBox(
                width: 130,
                height: 38,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Agendar',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExamCard(Map<String, dynamic> favorite) {
    final exam = _related(favorite['exames']);
    final clinic = _related(exam?['clinicas']);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.cardFill,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.science_outlined,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exam?['nome'] as String? ?? 'Exame',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkNavy,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${clinic?['nome'] ?? 'Clínica'} · ${clinic?['cidade'] ?? ''}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.slateText,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _removeFavorite(favorite['id'] as String),
                icon: const Icon(
                  Icons.favorite,
                  color: AppColors.primaryBlue,
                  size: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const SizedBox(width: 58),
              Expanded(
                child: SizedBox(
                  height: 36,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryBlue,
                      side: const BorderSide(color: AppColors.primaryBlue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Ver preparo',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 36,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Agendar',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
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
