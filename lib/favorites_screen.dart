import 'package:flutter/material.dart';
import 'app_colors.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  int _selectedFilter = 0; // 0: Todos, 1: Médicos, 2: Exames

  @override
  Widget build(BuildContext context) {
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
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.accentYellow,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '4',
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
              decoration: InputDecoration(
                hintText: 'Buscar nos favoritos',
                hintStyle: const TextStyle(color: AppColors.slateText, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: AppColors.slateText),
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
                  _buildSegmentTab(0, 'Todos (4)'),
                  _buildSegmentTab(1, 'Médicos (2)'),
                  _buildSegmentTab(2, 'Exames (2)'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Seção Médicos
            if (_selectedFilter == 0 || _selectedFilter == 1) ...[
              _buildSectionTitle('Médicos', '2'),
              const SizedBox(height: 12),
              _buildDoctorCard(
                name: 'Dra. Camila Ribeiro',
                specialty: 'Cardiologista',
                rating: '4,9 · 128 avaliações',
                clinic: 'Clínica Coração & Vida',
                imageUrl: 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=200',
              ),
              const SizedBox(height: 12),
              _buildDoctorCard(
                name: 'Dr. Rafael Martins',
                specialty: 'Clínico geral',
                rating: '4,8 · 96 avaliações',
                clinic: 'Clínica Saúde Integral',
                imageUrl: 'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=200',
              ),
              const SizedBox(height: 24),
            ],

            // Seção Exames
            if (_selectedFilter == 0 || _selectedFilter == 2) ...[
              _buildSectionTitle('Exames laboratoriais', '2'),
              const SizedBox(height: 12),
              _buildExamCard(
                title: 'Hemograma completo',
                lab: 'Laboratório Vida · Bela Vista',
              ),
              const SizedBox(height: 12),
              _buildExamCard(
                title: 'Glicemia em jejum',
                lab: 'Laboratório Vida · Bela Vista',
              ),
            ],
          ],
        ),
      ),
    );
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
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
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
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black),
        ),
        Text(
          count,
          style: const TextStyle(fontSize: 13, color: AppColors.slateText, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildDoctorCard({
    required String name,
    required String specialty,
    required String rating,
    required String clinic,
    required String imageUrl,
  }) {
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
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.darkNavy),
                    ),
                    const SizedBox(height: 2),
                    Text(specialty, style: const TextStyle(fontSize: 13, color: AppColors.slateText)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 16, color: AppColors.darkNavy),
                        const SizedBox(width: 4),
                        Text(
                          rating,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.darkNavy),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.favorite, color: AppColors.primaryBlue, size: 22),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(clinic, style: const TextStyle(fontSize: 12, color: AppColors.slateText)),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('Agendar', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExamCard({required String title, required String lab}) {
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
                child: const Icon(Icons.science_outlined, color: AppColors.primaryBlue),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.darkNavy),
                    ),
                    const SizedBox(height: 4),
                    Text(lab, style: const TextStyle(fontSize: 13, color: AppColors.slateText)),
                  ],
                ),
              ),
              const Icon(Icons.favorite, color: AppColors.primaryBlue, size: 22),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Text('Ver preparo', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Text('Agendar', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
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