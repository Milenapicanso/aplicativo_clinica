// Tela "Cadrastrar" do AppAgendamento: Cadastro, etapa 1 de 2 (Figma node 19:107).

import 'package:flutter/material.dart';

import 'auth.dart';

class RegisterPersonalScreen extends StatefulWidget {
  const RegisterPersonalScreen({super.key, this.onBack, this.onNext});

  final VoidCallback? onBack;

  /// Toque em "Próximo" com os dados da etapa 1.
  final void Function(String name, String cpf, String birthDate, String? sex)?
  onNext;

  @override
  State<RegisterPersonalScreen> createState() => _RegisterPersonalScreenState();
}

class _RegisterPersonalScreenState extends State<RegisterPersonalScreen> {
  // As opções de "Sexo" não aparecem no Figma, ajuste conforme o seu app.
  static const _sexOptions = [
    'Feminino',
    'Masculino',
    'Outro',
    'Prefiro não informar',
  ];

  final _name = TextEditingController();
  final _cpf = TextEditingController();
  final _birthDate = TextEditingController();
  String? _sex;

  @override
  void dispose() {
    _name.dispose();
    _cpf.dispose();
    _birthDate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      onBack: widget.onBack,
      footer: AuthPrimaryButton(
        label: 'Próximo',
        onPressed: () => widget.onNext?.call(
          _name.text.trim(),
          _cpf.text.trim(),
          _birthDate.text.trim(),
          _sex,
        ),
      ),
      children: [
        const SizedBox(height: 8),
        const StepProgress(step: 1),
        const SizedBox(height: 28),
        const AuthHeader(
          title: 'Cadastro',
          subtitle: 'Vamos começar com seus dados pessoais.',
          subtitleSize: 12,
          stepLabel: 'ETAPA 1 DE 2',
        ),
        const SizedBox(height: 24),
        AuthField(
          label: 'Nome Completo',
          hint: 'Digite seu nome completo',
          icon: Icons.person_outline_rounded,
          controller: _name,
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 10),
        AuthField(
          label: 'CPF',
          hint: '000.000.000-00',
          icon: Icons.badge_outlined,
          controller: _cpf,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 10),
        AuthField(
          label: 'Data de nascimento',
          hint: 'DD/MM/AAAA',
          icon: Icons.calendar_month_outlined,
          controller: _birthDate,
          keyboardType: TextInputType.datetime,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 10),
        AuthDropdownField(
          label: 'Sexo',
          hint: 'Selecione uma opção',
          icon: Icons.person_outline_rounded,
          items: _sexOptions,
          value: _sex,
          onChanged: (value) => setState(() => _sex = value),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
//parte 2

// Tela "Cadrastrar 2" do AppAgendamento: Cadastro, etapa 2 de 2 (Figma node 20:128).

class RegisterAccessScreen extends StatefulWidget {
  const RegisterAccessScreen({super.key, this.onBack, this.onFinish});

  final VoidCallback? onBack;

  /// Toque em "Concluir" (só é chamado quando as senhas coincidem).
  final void Function(String email, String phone, String password)? onFinish;

  @override
  State<RegisterAccessScreen> createState() => _RegisterAccessScreenState();
}

class _RegisterAccessScreenState extends State<RegisterAccessScreen> {
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  void _finish() {
    if (_password.text != _confirmPassword.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('As senhas não coincidem.')));
      return;
    }
    widget.onFinish?.call(
      _email.text.trim(),
      _phone.text.trim(),
      _password.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      onBack: widget.onBack,
      footer: AuthPrimaryButton(label: 'Concluir', onPressed: _finish),
      children: [
        const SizedBox(height: 8),
        const StepProgress(step: 2),
        const SizedBox(height: 28),
        const AuthHeader(
          title: 'Informações de acesso',
          titleSize: 24,
          subtitle: 'Agora, defina como acessar sua conta.',
          subtitleSize: 12,
          stepLabel: 'ETAPA 2 DE 2',
        ),
        const SizedBox(height: 24),
        AuthField(
          label: 'Email',
          hint: 'seuemail@exemplo.com',
          icon: Icons.mail_outline_rounded,
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 10),
        AuthField(
          label: 'Telefone',
          hint: '(00) 00000-0000',
          icon: Icons.phone_outlined,
          controller: _phone,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 10),
        AuthField(
          label: 'Cadastrar Senha',
          hint: 'Crie sua senha',
          icon: Icons.lock_outline_rounded,
          controller: _password,
          isPassword: true,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 10),
        AuthField(
          label: 'Confirmar Senha',
          hint: 'Repita sua senha',
          icon: Icons.lock_outline_rounded,
          controller: _confirmPassword,
          isPassword: true,
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
