import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tela Onboarding 1.
///
/// Convertida do Figma: arquivo "AppAgendamento", frame "Onboarding 1".
///
/// Requer o asset: assets/onboarding1_ilustracao.svg.svg.
/// (exportar do Figma o item "Ilustração · Agendamento médico").
///
/// Pacotes: flutter_svg e google_fonts (fonte Manrope).
class Onboarding1Tela extends StatelessWidget {
  const Onboarding1Tela({super.key, this.aoAcessar, this.aoCriarConta});

  /// Toque no botão "Acessar agora".
  final VoidCallback? aoAcessar;

  /// Toque em "Crie um agora".
  final VoidCallback? aoCriarConta;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: _Cores.fundo,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Ilustração · Agendamento médico (294 x 254,8)
                          Center(
                            child: SizedBox(
                              width: 294,
                              height: 254.8,
                              child: SvgPicture.asset(
                                'assets/onboarding1_ilustracao.svg.svg',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(height: 34),

                          // Apresentação
                          Text(
                            'Marque sua consulta ou exame em poucos cliques',
                            style: GoogleFonts.manrope(
                              fontSize: 27,
                              fontWeight: FontWeight.w700,
                              height: 34 / 27,
                              letterSpacing: -0.45,
                              color: _Cores.titulo,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Sem filas, sem ligações e sem complicação. '
                            'Escolha o médico, o dia e o horário que ficam '
                            'melhores para você.',
                            style: GoogleFonts.manrope(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              height: 22 / 14,
                              color: _Cores.subtitulo,
                            ),
                          ),

                          const SizedBox(height: 32),
                          const Spacer(),

                          // Botão "Acessar agora"
                          _BotaoAcessar(onTap: aoAcessar),
                          const SizedBox(height: 24),

                          // "Não tem uma conta? Crie um agora"
                          Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Não tem uma conta? ',
                                  style: GoogleFonts.manrope(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    height: 22 / 14,
                                    color: _Cores.link,
                                  ),
                                ),
                                InkWell(
                                  onTap: aoCriarConta,
                                  borderRadius: BorderRadius.circular(4),
                                  child: Text(
                                    'Crie um agora',
                                    style: GoogleFonts.manrope(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      height: 22 / 14,
                                      color: _Cores.link,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Botão com degradê azul (#3A9AFF -> #261CC1), 54 de altura, cantos 15.
class _BotaoAcessar extends StatelessWidget {
  const _BotaoAcessar({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(15),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        height: 54,
        decoration: const BoxDecoration(
          // Ângulo de 159° do Figma, convertido para alinhamentos do Flutter.
          gradient: LinearGradient(
            begin: Alignment(-0.183, -2.862),
            end: Alignment(0.183, 2.862),
            colors: [_Cores.botaoInicio, _Cores.botaoFim, _Cores.botaoFim],
            stops: [0.0, 0.86957, 1.0],
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: Center(
            child: Text(
              'Acessar agora',
              style: GoogleFonts.manrope(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                height: 22 / 15,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Cores tiradas do Figma.
class _Cores {
  static const fundo = Color(0xFFF5EFFF);
  static const titulo = Color(0xFF182C47);
  static const subtitulo = Color(0xFF52637A);
  static const link = Color(0xFF264763);
  static const botaoInicio = Color(0xFF3A9AFF);
  static const botaoFim = Color(0xFF261CC1);
}
