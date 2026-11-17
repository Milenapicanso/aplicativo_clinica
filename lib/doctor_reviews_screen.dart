// Tela "Perfil da médica" com avaliações dos pacientes (Figma node 71:25).
//
// Fonte: Manrope (google_fonts).
// No Figma os "halos" do cabeçalho são SVGs; aqui foram aproximados com
// círculos translúcidos.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class _C {
  static const ink = Color(0xFF19354B);
  static const muted = Color(0xFF52677D);
  static const slate600 = Color(0xFF475569);
  static const slate500 = Color(0xFF64748B);
  static const border = Color(0xFFE5EBF4);
  static const panel = Color(0xFFE2EAFC);
  static const blue = Color(0xFF261CC1);
  static const star = Color(0xFFA37000);
}

class PatientReview {
  const PatientReview({
    required this.author,
    required this.date,
    required this.mode,
    required this.comment,
    this.stars = 5,
  });

  final String author;
  final String date;
  final String mode;
  final String comment;
  final int stars;
}

const _sampleReviews = [
  PatientReview(
    author: 'Mariana S.',
    date: '12 nov. 2026',
    mode: 'Consulta presencial',
    comment: 'Atenciosa e muito clara nas explicações. Saí da consulta entendendo melhor os cuidados com meu coração.',
  ),
  PatientReview(
    author: 'João P.',
    date: '10 nov. 2026',
    mode: 'Consulta presencial',
    comment: 'Consulta tranquila, sem pressa. A doutora ouviu minhas dúvidas e explicou cada orientação.',
  ),
];

class DoctorReviewsScreen extends StatelessWidget {
  const DoctorReviewsScreen({
    super.key,
    this.doctorName = 'Dra. Camila Ribeiro',
    this.initials = 'CR',
    this.crm,
    this.yearsOfExperience,
    this.specialties = const [],
    this.rating = '4,9',
    this.distribution = const {5: 115, 4: 12, 3: 1, 2: 0, 1: 0},
    this.reviews = _sampleReviews,
    this.isFavorite = true,
    this.onBack,
    this.onToggleFavorite,
  });

  final String doctorName;
  final String initials;

  /// Quando nulos, mostra "Não informado".
  final String? crm;
  final String? yearsOfExperience;

  /// Quando vazia, mostra "Não informadas".
  final List<String> specialties;

  final String rating;

  /// Quantidade de avaliações por nota (5 a 1).
  final Map<int, int> distribution;
  final List<PatientReview> reviews;
  final bool isFavorite;
  final VoidCallback? onBack;
  final VoidCallback? onToggleFavorite;

  int get _total => distribution.values.fold(0, (a, b) => a + b);

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FC),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        // Ícones claros da barra de status sobre o degradê azul.
        value: SystemUiOverlayStyle.light,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _Header(
                top: top,
                doctorName: doctorName,
                initials: initials,
                isFavorite: isFavorite,
                onBack: onBack,
                onToggleFavorite: onToggleFavorite,
              ),
              // Os 40px de cima ficam sobre o degradê, para os cantos
              // arredondados do painel mostrarem o azul atrás.
              Stack(
                children: [
                  const Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 40,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF3A9AFF), Color(0xFF261CC1)],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(
                      24,
                      24,
                      24,
                      24 + MediaQuery.of(context).padding.bottom,
                    ),
                    decoration: const BoxDecoration(
                      color: _C.panel,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(40),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _title('Informações profissionais', 18),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _InfoCard(
                                label: 'CRM',
                                value: crm ?? 'Não informado',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _InfoCard(
                                label: 'Anos de experiência',
                                value: yearsOfExperience ?? 'Não informado',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _SpecialtiesCard(specialties: specialties),
                        const SizedBox(height: 24),
                        _title('Avaliações dos pacientes', 18),
                        const SizedBox(height: 16),
                        _RatingSummary(
                          rating: rating,
                          distribution: distribution,
                          total: _total,
                        ),
                        const SizedBox(height: 22),
                        _title('Comentários dos pacientes', 17),
                        const SizedBox(height: 16),
                        for (final review in reviews)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _ReviewCard(review: review),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _title(String text, double size) => Text(
    text,
    style: GoogleFonts.manrope(
      fontSize: size,
      fontWeight: FontWeight.w700,
      height: 1.45,
      color: _C.ink,
    ),
  );
}

class _Header extends StatelessWidget {
  const _Header({
    required this.top,
    required this.doctorName,
    required this.initials,
    required this.isFavorite,
    this.onBack,
    this.onToggleFavorite,
  });

  final double top;
  final String doctorName;
  final String initials;
  final bool isFavorite;
  final VoidCallback? onBack;
  final VoidCallback? onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    // As posições do Figma (barra de status de 42px) valem a partir de [top].
    return Container(
      height: top + 247,
      width: double.infinity,
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3A9AFF), Color(0xFF261CC1)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(right: -93, top: -85, child: _halo(260, 0.10)),
          Positioned(left: -120, top: 160, child: _halo(280, 0.12)),
          Positioned(right: -38, top: 140, child: _halo(170, 0.08)),
          // Voltar
          Positioned(
            left: 24,
            top: top + 12,
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: onBack,
                borderRadius: BorderRadius.circular(12),
                child: const SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(
                    Icons.chevron_left_rounded,
                    size: 24,
                    color: _C.blue,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 80,
            top: top + 20,
            child: Text(
              'Perfil da médica',
              style: GoogleFonts.manrope(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                height: 30 / 17,
                color: Colors.white,
              ),
            ),
          ),
          // Favorito
          Positioned(
            right: 18,
            top: top + 28,
            child: Material(
              color: _C.blue,
              borderRadius: BorderRadius.circular(5),
              child: InkWell(
                onTap: onToggleFavorite,
                borderRadius: BorderRadius.circular(5),
                child: SizedBox(
                  width: 39,
                  height: 39,
                  child: Icon(
                    isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                    size: 26,
                    color: const Color(0xFFFFD54A),
                  ),
                ),
              ),
            ),
          ),
          // Avatar
          Positioned(
            top: top + 59,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 88,
                height: 88,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: const Color(0x59FFFFFF), width: 5),
                ),
                child: Text(
                  initials,
                  style: GoogleFonts.manrope(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF214F83),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: top + 160,
            left: 24,
            right: 24,
            child: Text(
              doctorName,
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                fontSize: 23,
                fontWeight: FontWeight.w600,
                height: 34 / 23,
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            top: top + 204,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 150,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0x29FFFFFF),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Text(
                  'Perfil profissional',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _halo(double size, double opacity) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white.withValues(alpha: opacity),
    ),
  );
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 86,
      padding: const EdgeInsets.fromLTRB(15, 12, 15, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _C.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 1.45,
              color: _C.muted,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 1.45,
              color: _C.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _SpecialtiesCard extends StatelessWidget {
  const _SpecialtiesCard({required this.specialties});

  final List<String> specialties;

  @override
  Widget build(BuildContext context) {
    final labels = specialties.isEmpty ? const ['Não informadas'] : specialties;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(15, 11, 15, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _C.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Especialidades',
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.45,
              color: _C.ink,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final label in labels)
                Container(
                  height: 29,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDF2FB),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    label,
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _C.muted,
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

class _RatingSummary extends StatelessWidget {
  const _RatingSummary({
    required this.rating,
    required this.distribution,
    required this.total,
  });

  final String rating;
  final Map<int, int> distribution;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 14, 15, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 126,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      rating,
                      style: GoogleFonts.manrope(
                        fontSize: 42,
                        fontWeight: FontWeight.w700,
                        height: 52 / 42,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        'de 5',
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _C.slate500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '★★★★★',
                  style: GoogleFonts.manrope(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    height: 27 / 19,
                    color: _C.star,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '$total avaliações',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    height: 20 / 12,
                    color: _C.slate600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                for (var stars = 5; stars >= 1; stars--)
                  _DistributionRow(
                    stars: stars,
                    count: distribution[stars] ?? 0,
                    fraction: total == 0
                        ? 0
                        : (distribution[stars] ?? 0) / total,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DistributionRow extends StatelessWidget {
  const _DistributionRow({
    required this.stars,
    required this.count,
    required this.fraction,
  });

  final int stars;
  final int count;
  final double fraction;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      child: Row(
        children: [
          SizedBox(
            width: 23,
            child: Text(
              '$stars',
              style: GoogleFonts.manrope(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _C.slate600,
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: fraction.clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: const Color(0xFFEDF1F7),
                valueColor: const AlwaysStoppedAnimation(_C.blue),
              ),
            ),
          ),
          SizedBox(
            width: 45,
            child: Text(
              '$count',
              textAlign: TextAlign.right,
              style: GoogleFonts.manrope(fontSize: 11, color: _C.slate500),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final PatientReview review;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(15, 13, 15, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                review.author,
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 22 / 14,
                  color: const Color(0xFF111827),
                ),
              ),
              Text(
                review.date,
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  height: 20 / 11,
                  color: _C.slate500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Text(
                '★' * review.stars,
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 22 / 14,
                  color: _C.star,
                ),
              ),
              const SizedBox(width: 15),
              Text(
                review.mode,
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  height: 20 / 11,
                  color: _C.slate500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            review.comment,
            style: GoogleFonts.manrope(
              fontSize: 12,
              height: 20 / 12,
              color: _C.slate600,
            ),
          ),
        ],
      ),
    );
  }
}
