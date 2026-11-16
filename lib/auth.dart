// Componentes compartilhados das telas Login e Cadastro (etapas 1 e 2).
// Fontes: Manrope nos títulos e Poppins nos demais textos (google_fonts).

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthColors {
  static const primary = Color(0xFF2743BA);
  static const fieldBackground = Color(0xFFF6F6FA);
  static const textPrimary = Color(0xFF111318);
  static const textSecondary = Color(0xFF727985);
  static const hint = Color(0xFF858B98);
  static const divider = Color(0xFFEBEDF2);
  static const handle = Color(0xFFDEE1E8);
  static const stepPending = Color(0xFFDDE7F4);
  static const stepDone = Color(0xFFB2C8EE);
}

class AuthText {
  static TextStyle title([double size = 26]) => GoogleFonts.manrope(
        fontSize: size,
        fontWeight: FontWeight.w600,
        height: 1.5,
        color: AuthColors.textPrimary,
      );

  static TextStyle subtitle([double size = 13]) => GoogleFonts.poppins(
        fontSize: size,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: AuthColors.textSecondary,
      );

  static TextStyle label() => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.5,
        color: AuthColors.textPrimary,
      );

  static TextStyle input() => GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AuthColors.textPrimary,
      );

  static TextStyle hint() => GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AuthColors.hint,
      );

  static TextStyle link(double size) => GoogleFonts.poppins(
        fontSize: size,
        fontWeight: FontWeight.w500,
        height: 1.5,
        color: AuthColors.primary,
      );
}

/// Fundo azul com o painel branco arredondado, o "puxador" no topo
/// e, opcionalmente, o link "Voltar" e um rodapé fixo (botão).
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.children,
    this.footer,
    this.onBack,
  });

  final List<Widget> children;
  final Widget? footer;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      // Ícones claros da barra de status sobre o fundo azul.
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AuthColors.primary,
        body: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Container(
                      width: 63,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AuthColors.handle,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    if (onBack != null)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 28, top: 11),
                          child: InkWell(
                            onTap: onBack,
                            child: SizedBox(
                              height: 22,
                              child: Text('Voltar', style: AuthText.link(11)),
                            ),
                          ),
                        ),
                      ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: children,
                        ),
                      ),
                    ),
                    if (footer != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                        child: footer,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Título, subtítulo e (opcional) "ETAPA X DE 2".
class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.titleSize = 26,
    this.subtitleSize = 13,
    this.stepLabel,
  });

  final String title;
  final String subtitle;
  final double titleSize;
  final double subtitleSize;
  final String? stepLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title, textAlign: TextAlign.center, style: AuthText.title(titleSize)),
        const SizedBox(height: 6),
        Text(subtitle, textAlign: TextAlign.center, style: AuthText.subtitle(subtitleSize)),
        if (stepLabel != null) ...[
          const SizedBox(height: 17),
          Text(
            stepLabel!,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              height: 1.5,
              color: AuthColors.primary,
            ),
          ),
        ],
      ],
    );
  }
}

/// Barra de duas etapas do cadastro. [step] é 1 ou 2.
class StepProgress extends StatelessWidget {
  const StepProgress({super.key, required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    final first = step == 1 ? AuthColors.primary : AuthColors.stepDone;
    final second = step == 1 ? AuthColors.stepPending : AuthColors.primary;

    Widget bar(Color color) => Expanded(
          child: Container(
            height: 5,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );

    return Row(children: [bar(first), const SizedBox(width: 10), bar(second)]);
  }
}

/// Rótulo + campo cinza arredondado com ícone à esquerda.
class AuthField extends StatefulWidget {
  const AuthField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    this.controller,
    this.keyboardType,
    this.textInputAction,
    this.isPassword = false,
  });

  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool isPassword;

  @override
  State<AuthField> createState() => _AuthFieldState();
}

class _AuthFieldState extends State<AuthField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return _FieldShell(
      label: widget.label,
      child: Row(
        children: [
          const SizedBox(width: 16),
          Icon(widget.icon, size: 20, color: AuthColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: widget.controller,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              obscureText: widget.isPassword && _obscure,
              style: AuthText.input(),
              cursorColor: AuthColors.primary,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintText: widget.hint,
                hintStyle: AuthText.hint(),
              ),
            ),
          ),
          if (widget.isPassword)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                onPressed: () => setState(() => _obscure = !_obscure),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                iconSize: 20,
                color: AuthColors.hint,
                icon: Icon(
                  _obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
              ),
            )
          else
            const SizedBox(width: 16),
        ],
      ),
    );
  }
}

/// Mesmo visual do [AuthField], mas com lista de opções.
class AuthDropdownField extends StatelessWidget {
  const AuthDropdownField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.items,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String hint;
  final IconData icon;
  final List<String> items;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return _FieldShell(
      label: label,
      child: Row(
        children: [
          const SizedBox(width: 16),
          Icon(icon, size: 20, color: AuthColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                hint: Text(hint, style: AuthText.hint()),
                style: AuthText.input(),
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(12),
                icon: const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: AuthColors.primary,
                  ),
                ),
                items: [
                  for (final item in items)
                    DropdownMenuItem(value: item, child: Text(item)),
                ],
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldShell extends StatelessWidget {
  const _FieldShell({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 2),
            child: Text(label, style: AuthText.label()),
          ),
          const SizedBox(height: 11),
          Container(
            height: 56,
            decoration: BoxDecoration(
              color: AuthColors.fieldBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}

/// Botão azul de 58px usado em "Entrar", "Próximo" e "Concluir".
class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({super.key, required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(15);
    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [AuthColors.primary, Color(0xFF4775E8)],
        ),
        boxShadow: [
          BoxShadow(
            color: AuthColors.primary.withValues(alpha: 0.28),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: onPressed,
          borderRadius: radius,
          splashColor: Colors.white.withValues(alpha: 0.18),
          highlightColor: Colors.white.withValues(alpha: 0.08),
          child: SizedBox(
            height: 58,
            child: Center(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}