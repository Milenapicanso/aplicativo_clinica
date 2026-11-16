// Tela "Onboarding 1" do AppAgendamento (Figma node 18:17).
//
// Dependência: google_fonts (fonte Manrope)
//   flutter pub add google_fonts
//
// A barra de status (9:41, sinal, bateria) e o indicador de gesto do Figma
// são só moldura de celular, o próprio sistema desenha isso no app real.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class _AppColors {
  static const background = Color(0xFFFBFBFB);
  static const title = Color(0xFF182C47);
  static const body = Color(0xFF627389);
  static const link = Color(0xFF264763);
  static const gradientStart = Color(0xFF3A9AFF);
  static const gradientEnd = Color(0xFF261CC1);
}

class Onboarding1Screen extends StatelessWidget {
  const Onboarding1Screen({
    super.key,
    this.onAccess,
    this.onCreateAccount,
  });

  /// Toque em "Acessar agora".
  final VoidCallback? onAccess;

  /// Toque em "Crie um agora".
  final VoidCallback? onCreateAccount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Text(
                'Agende sua consulta ou exame em poucos cliques',
                style: GoogleFonts.manrope(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  height: 35 / 28,
                  color: _AppColors.title,
                ),
              ),
              const SizedBox(height: 0),
              Text(
                'Sem filas, sem ligações e sem complicação. Escolha o médico, '
                'o dia e o horário que ficam melhores para você.',
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 22 / 14,
                  color: _AppColors.body,
                ),
              ),
              const SizedBox(height: 63),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: _GradientButton(
                  label: 'Acessar agora',
                  onPressed: onAccess,
                ),
              ),
              const SizedBox(height: 44),
              Center(
                child: TextButton(
                  onPressed: onCreateAccount,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    foregroundColor: _AppColors.link,
                  ),
                  child: Text.rich(
                    TextSpan(
                      style: GoogleFonts.manrope(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        height: 22 / 15,
                        color: _AppColors.link,
                      ),
                      children: [
                        const TextSpan(text: 'Não tem uma conta?'),
                        TextSpan(
                          text: ' Crie um agora',
                          style: GoogleFonts.manrope(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            height: 22 / 15,
                            color: _AppColors.link,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(15);

    return Ink(
      height: 52,
      decoration: BoxDecoration(
        borderRadius: radius,
        // Figma: linear-gradient(159.76deg, #3A9AFF 0%, #261CC1 86.957%)
        gradient: const LinearGradient(
          begin: Alignment(-0.34, -0.94),
          end: Alignment(0.34, 0.94),
          colors: [_AppColors.gradientStart, _AppColors.gradientEnd],
          stops: [0.0, 0.86957],
        ),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: radius,
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 22 / 15,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}