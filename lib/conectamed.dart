import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Tela inicial (splash) do ConectaMed.
///
/// Convertida do Figma: arquivo "AppAgendamento",
/// frame "ConectaMed · Tela inicial" (390 x 844).
///
/// Requer o asset: assets/Logo_ConectaMed.png.
///
/// Uso:
/// ```dart
/// ConectaMedTelaInicial(
///   aoFinalizar: () => Navigator.of(context).pushReplacement(...),
/// )
/// ```
class ConectaMedTelaInicial extends StatefulWidget {
  const ConectaMedTelaInicial({
    super.key,
    this.aoFinalizar,
    this.duracao = const Duration(milliseconds: 2800),
    this.animar = true,
  });

  /// Chamado depois de [duracao]. Use para navegar para a próxima tela.
  final VoidCallback? aoFinalizar;

  /// Tempo que a tela fica visível antes de chamar [aoFinalizar].
  final Duration duracao;

  /// Se false, mostra a tela exatamente como está no Figma, sem movimento.
  final bool animar;

  @override
  State<ConectaMedTelaInicial> createState() => _ConectaMedTelaInicialState();
}

class _ConectaMedTelaInicialState extends State<ConectaMedTelaInicial>
    with TickerProviderStateMixin {
  // Tamanho do frame no Figma. Todas as posições abaixo usam essas medidas.
  static const double _larguraFrame = 390;
  static const double _alturaFrame = 844;

  late final AnimationController _entrada;
  late final AnimationController _pulso;
  late final AnimationController _pontos;

  late final Animation<double> _opacidadeLogo;
  late final Animation<double> _escalaLogo;
  late final Animation<double> _opacidadeFundo;
  late final Animation<double> _pulsoCurva;

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _entrada = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _pulso = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );
    _pontos = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _opacidadeLogo = CurvedAnimation(
      parent: _entrada,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );
    _escalaLogo = Tween<double>(
      begin: 0.92,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _entrada, curve: Curves.easeOutCubic));
    _opacidadeFundo = CurvedAnimation(parent: _entrada, curve: Curves.easeOut);
    _pulsoCurva = CurvedAnimation(parent: _pulso, curve: Curves.easeInOut);

    if (widget.animar) {
      _entrada.forward();
      _pulso.repeat(reverse: true);
      _pontos.repeat();
    } else {
      _entrada.value = 1;
    }

    final aoFinalizar = widget.aoFinalizar;
    if (aoFinalizar != null) {
      _timer = Timer(widget.duracao, aoFinalizar);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _entrada.dispose();
    _pulso.dispose();
    _pontos.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: _Cores.fundoBase,
        body: SizedBox.expand(
          child: ClipRect(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _larguraFrame,
                height: _alturaFrame,
                child: Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    // Fundo · luz azul suave
                    const Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              _Cores.fundoTopo,
                              _Cores.fundoMeio,
                              _Cores.fundoFim,
                            ],
                            stops: [0.0, 0.48, 1.0],
                          ),
                        ),
                      ),
                    ),

                    // Brilho ciano · inferior
                    _brilho(
                      x: 90,
                      y: 490,
                      tamanho: 540,
                      inicio: _Cores.brilhoCianoInicio,
                      fim: _Cores.brilhoCianoFim,
                    ),

                    // Brilho azul · superior
                    _brilho(
                      x: -245,
                      y: -180,
                      tamanho: 570,
                      inicio: _Cores.brilhoAzulInicio,
                      fim: _Cores.brilhoAzulFim,
                    ),

                    // Halo da marca
                    Positioned(
                      left: -35,
                      top: 190,
                      width: 460,
                      height: 460,
                      child: FadeTransition(
                        opacity: _opacidadeFundo,
                        child: const DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [_Cores.haloInicio, _Cores.haloFim],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Ondas de conexão (470, 590 e 710)
                    _onda(
                      x: -40,
                      y: 187,
                      tamanho: 470,
                      opacidade: 0.09,
                      amplitude: 0.012,
                    ),
                    _onda(
                      x: -100,
                      y: 127,
                      tamanho: 590,
                      opacidade: 0.055,
                      amplitude: 0.020,
                    ),
                    _onda(
                      x: -160,
                      y: 67,
                      tamanho: 710,
                      opacidade: 0.035,
                      amplitude: 0.028,
                    ),

                    // Logo ConectaMed
                    Positioned(
                      left: -70,
                      top: 229,
                      width: 530,
                      height: 409.975,
                      child: FadeTransition(
                        opacity: _opacidadeLogo,
                        child: ScaleTransition(
                          scale: _escalaLogo,
                          child: Image.asset(
                            'assets/Logo_ConectaMed.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),

                    // Carregamento · 3 pontos
                    _pontosCarregamento(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Círculo com degradê radial (brilhos de fundo).
  Widget _brilho({
    required double x,
    required double y,
    required double tamanho,
    required Color inicio,
    required Color fim,
  }) {
    return Positioned(
      left: x,
      top: y,
      width: tamanho,
      height: tamanho,
      child: FadeTransition(
        opacity: _opacidadeFundo,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [inicio, fim]),
          ),
        ),
      ),
    );
  }

  /// Anel fino ao redor da logo. Pulsa de leve quando [animar] é true.
  Widget _onda({
    required double x,
    required double y,
    required double tamanho,
    required double opacidade,
    required double amplitude,
  }) {
    return Positioned(
      left: x,
      top: y,
      width: tamanho,
      height: tamanho,
      child: FadeTransition(
        opacity: _opacidadeFundo,
        child: ScaleTransition(
          scale: Tween<double>(
            begin: 1.0,
            end: 1.0 + amplitude,
          ).animate(_pulsoCurva),
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Color.fromRGBO(26, 148, 204, opacidade),
                width: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Três pontos. No Figma o primeiro está ativo (75%) e os outros a 16%.
  /// Na animação, o destaque passa de um ponto para o outro.
  Widget _pontosCarregamento() {
    return Positioned(
      left: 177,
      top: 747,
      width: 36,
      height: 6,
      child: AnimatedBuilder(
        animation: _pontos,
        builder: (context, _) {
          final fase = _pontos.value * 3;
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(3, (i) {
              final d = (fase - i) % 3;
              final distancia = d < 3 - d ? d : 3 - d;
              final forca = (1 - distancia).clamp(0.0, 1.0).toDouble();
              final opacidade = 0.16 + (0.75 - 0.16) * forca;
              return Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromRGBO(10, 51, 122, opacidade),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

/// Cores tiradas do Figma.
class _Cores {
  static const fundoBase = Color(0xFFF5FAFF);
  static const fundoTopo = Color(0xFFE8F5FF);
  static const fundoMeio = Color(0xFFFAFDFF);
  static const fundoFim = Color(0xFFE5F7FC);

  // Brilho ciano (inferior): #33C7E8, 19% -> 0%
  static const brilhoCianoInicio = Color.fromRGBO(51, 199, 232, 0.19);
  static const brilhoCianoFim = Color.fromRGBO(51, 199, 232, 0.0);

  // Brilho azul (superior): #3385E8, 10% -> 0%
  static const brilhoAzulInicio = Color.fromRGBO(51, 133, 232, 0.10);
  static const brilhoAzulFim = Color.fromRGBO(51, 133, 232, 0.0);

  // Halo da marca: branco, 95% -> 0%
  static const haloInicio = Color.fromRGBO(255, 255, 255, 0.95);
  static const haloFim = Color.fromRGBO(255, 255, 255, 0.0);
}
