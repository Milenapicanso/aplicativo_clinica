// Tela "Cadrastrar" do AppAgendamento: Cadastro, etapa 1 de 2 (Figma node 19:107).

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthException;

import 'auth.dart';
import 'supabase_client.dart';

class BirthDateInputFormatter extends TextInputFormatter {
  const BirthDateInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final selectionOffset = newValue.selection.extentOffset
        .clamp(0, newValue.text.length)
        .toInt();
    final digitsBeforeCursor = newValue.text
        .substring(0, selectionOffset)
        .replaceAll(RegExp(r'\D'), '')
        .length;
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limitedDigits = digits.length > 8 ? digits.substring(0, 8) : digits;
    final formatted = StringBuffer();

    for (var index = 0; index < limitedDigits.length; index++) {
      if (index == 2 || index == 4) formatted.write('/');
      formatted.write(limitedDigits[index]);
    }

    final cursorDigits = digitsBeforeCursor > limitedDigits.length
        ? limitedDigits.length
        : digitsBeforeCursor;
    final cursorOffset =
        cursorDigits + (cursorDigits > 2 ? 1 : 0) + (cursorDigits > 4 ? 1 : 0);
    return TextEditingValue(
      text: formatted.toString(),
      selection: TextSelection.collapsed(offset: cursorOffset),
    );
  }
}

String? _personalDataError({
  required String name,
  required String cpf,
  required String birthDate,
}) {
  if (name.trim().isEmpty) return 'Informe seu nome completo.';
  if (cpf.replaceAll(RegExp(r'\D'), '').length != 11) {
    return 'O CPF deve conter 11 números.';
  }
  if (_birthDateToIso(birthDate) == null) {
    return 'Informe uma data válida no formato DD/MM/AAAA.';
  }
  return null;
}

String? _birthDateToIso(String value) {
  final parts = value.split('/');
  if (parts.length != 3) return null;
  final day = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final year = int.tryParse(parts[2]);
  if (day == null || month == null || year == null) return null;
  final date = DateTime(year, month, day);
  if (date.year != year || date.month != month || date.day != day) {
    return null;
  }
  return '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

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

  void _continue() {
    final error = _personalDataError(
      name: _name.text,
      cpf: _cpf.text,
      birthDate: _birthDate.text,
    );
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    widget.onNext?.call(
      _name.text.trim(),
      _cpf.text.trim(),
      _birthDate.text.trim(),
      _sex,
    );
  }

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
      footer: AuthPrimaryButton(label: 'Próximo', onPressed: _continue),
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
          keyboardType: TextInputType.number,
          inputFormatters: const [BirthDateInputFormatter()],
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
  const RegisterAccessScreen({
    super.key,
    this.name = '',
    this.cpf = '',
    this.birthDate = '',
    this.sex,
    this.onBack,
    this.onFinish,
  });

  final String name;
  final String cpf;
  final String birthDate;
  final String? sex;
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
  bool _isSubmitting = false;

  @override
  void dispose() {
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    if (_password.text != _confirmPassword.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('As senhas não coincidem.')));
      return;
    }

    if (_isSubmitting) return;
    final email = _email.text.trim().toLowerCase();
    final phone = _phone.text.trim();
    final cpf = widget.cpf.replaceAll(RegExp(r'\D'), '');
    final birthDate = _birthDateToIso(widget.birthDate);
    final personalDataError = _personalDataError(
      name: widget.name,
      cpf: cpf,
      birthDate: widget.birthDate,
    );
    if (personalDataError != null || email.isEmpty || birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            personalDataError ??
                (email.isEmpty
                    ? 'Informe seu e-mail.'
                    : 'Informe uma data válida no formato DD/MM/AAAA.'),
          ),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: _password.text,
        data: {
          'nome': widget.name.trim(),
          'telefone': phone,
          'data_nascimento': birthDate,
          'cpf': cpf,
          'sexo': widget.sex,
          'tipo': 'paciente',
        },
      );
      if (!mounted) return;
      if (response.session == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'O Supabase ainda exige confirmação do e-mail. Para entrar direto, desative “Confirm email” em Authentication > Sign In / Providers > Email no painel do Supabase.',
            ),
          ),
        );
        return;
      }
      widget.onFinish?.call(email, phone, _password.text);
    } on AuthException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      onBack: widget.onBack,
      footer: AuthPrimaryButton(
        label: _isSubmitting ? 'Criando conta...' : 'Concluir',
        onPressed: _isSubmitting ? null : _finish,
      ),
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
