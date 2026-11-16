// Tela "Tela Login" do AppAgendamento (Figma node 2:30).

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    this.onSubmit,
    this.onForgotPassword,
    this.onGoogle,
    this.onRegister,
  });

  /// Toque em "Entrar".
  final void Function(String email, String password)? onSubmit;

  /// Toque em "esqueceu a senha?".
  final VoidCallback? onForgotPassword;

  /// Toque em "Google".
  final VoidCallback? onGoogle;

  /// Toque em "Cadastrar".
  final VoidCallback? onRegister;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      children: [
        const SizedBox(height: 66),
        const AuthHeader(
          title: 'Fazer Login',
          subtitle: 'Acesse sua conta para continuar seu cuidado.',
        ),
        const SizedBox(height: 70),
        AuthField(
          label: 'Email',
          hint: 'seuemail@exemplo.com',
          icon: Icons.mail_outline_rounded,
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 14),
        AuthField(
          label: 'Senha',
          hint: 'Digite sua senha',
          icon: Icons.lock_outline_rounded,
          controller: _password,
          isPassword: true,
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: 18),
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 4),
            child: InkWell(
              onTap: widget.onForgotPassword,
              child: Text('esqueceu a senha?', style: AuthText.link(12)),
            ),
          ),
        ),
        const SizedBox(height: 34),
        AuthPrimaryButton(
          label: 'Entrar',
          onPressed: () => widget.onSubmit?.call(_email.text.trim(), _password.text),
        ),
        const SizedBox(height: 28),
        _OrDivider(),
        const SizedBox(height: 17),
        Center(child: _GoogleButton(onPressed: widget.onGoogle)),
        const SizedBox(height: 34),
        Center(
          child: InkWell(
            onTap: widget.onRegister,
            child: Text.rich(
              TextSpan(
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                  color: AuthColors.textPrimary,
                ),
                children: [
                  const TextSpan(text: 'Ainda não tem uma conta? '),
                  TextSpan(text: 'Cadastrar', style: AuthText.link(11)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _OrDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget line() => Container(width: 76, height: 1, color: AuthColors.divider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        children: [
          line(),
          Expanded(
            child: Text(
              'ou continue com',
              textAlign: TextAlign.center,
              style: AuthText.subtitle(11),
            ),
          ),
          line(),
        ],
      ),
    );
  }
}

class _GoogleButton extends StatelessWidget {
  const _GoogleButton({this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12);
    return Material(
      color: AuthColors.fieldBackground,
      borderRadius: radius,
      child: InkWell(
        onTap: onPressed,
        borderRadius: radius,
        child: SizedBox(
          width: 169,
          height: 48,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'G',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AuthColors.primary,
                ),
              ),
              const SizedBox(width: 24),
              Text(
                'Google',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AuthColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}