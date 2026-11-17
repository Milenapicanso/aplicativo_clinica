import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthException;

import 'app_colors.dart';
import 'supabase_client.dart';
import 'supabase_repository.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.onSignOut});

  final VoidCallback? onSignOut;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _biometricsEnabled = false;
  late Future<Map<String, dynamic>?> _profile;

  @override
  void initState() {
    super.initState();
    _profile = loadCurrentProfile();
  }

  Future<void> _signOut() async {
    try {
      await supabase.auth.signOut();
      if (mounted) widget.onSignOut?.call();
    } on AuthException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _profile,
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
                'Não foi possível carregar o perfil: ${snapshot.error}',
              ),
            ),
          );
        }
        final profile = snapshot.data;
        if (profile == null) {
          return const Scaffold(
            body: Center(child: Text('Entre na sua conta para ver o perfil.')),
          );
        }
        return _buildProfile(context, profile);
      },
    );
  }

  Widget _buildProfile(BuildContext context, Map<String, dynamic> profile) {
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
                  'Meu perfil',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.logout_rounded,
                      color: AppColors.logoutRed,
                      size: 20,
                    ),
                    onPressed: _signOut,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Card do Paciente
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardFill,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_outline,
                      color: AppColors.primaryBlue,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile['nome'] as String? ?? 'Paciente',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkNavy,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          profile['email'] as String? ?? '',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.slateText,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: const LinearProgressIndicator(
                            value: 0.7,
                            minHeight: 5,
                            backgroundColor: Color(0xFFDCE3EE),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primaryBlue,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Perfil 70% completo',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.slateText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.slateText,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildSectionHeader('DADOS E CONVÊNIOS'),
            _buildMenuGroup([
              _MenuItemData(
                Icons.person_outline,
                'Dados pessoais',
                isYellowBg: true,
              ),
              _MenuItemData(
                Icons.credit_card_outlined,
                'Convênios',
                isYellowBg: true,
              ),
              _MenuItemData(
                Icons.people_outline,
                'Dependentes e familiares',
                isYellowBg: true,
              ),
              _MenuItemData(
                Icons.location_on_outlined,
                'Endereços salvos',
                isYellowBg: true,
              ),
            ]),
            const SizedBox(height: 24),

            _buildSectionHeader('SEGURANÇA'),
            _buildMenuGroup([
              _MenuItemData(Icons.lock_outline_rounded, 'Alterar senha'),
              _MenuItemData(
                Icons.fingerprint_rounded,
                'Entrar com biometria',
                trailing: Switch(
                  value: _biometricsEnabled,
                  activeThumbColor: AppColors.primaryBlue,
                  onChanged: (val) => setState(() => _biometricsEnabled = val),
                ),
              ),
            ]),
            const SizedBox(height: 24),

            _buildSectionHeader('MAIS'),
            _buildMenuGroup([
              _MenuItemData(
                Icons.notifications_none_rounded,
                'Preferências de notificação',
              ),
              _MenuItemData(Icons.shield_outlined, 'Privacidade e termos'),
              _MenuItemData(Icons.headset_mic_outlined, 'Ajuda e suporte'),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: AppColors.slateText,
        ),
      ),
    );
  }

  Widget _buildMenuGroup(List<_MenuItemData> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isLast = index == items.length - 1;
          return Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                leading: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: item.isYellowBg
                        ? AppColors.softYellowBg
                        : AppColors.cardFill,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    item.icon,
                    color: AppColors.primaryBlue,
                    size: 20,
                  ),
                ),
                title: Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.darkNavy,
                  ),
                ),
                trailing:
                    item.trailing ??
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.slateText,
                    ),
                onTap: item.trailing == null ? () {} : null,
              ),
              if (!isLast)
                const Divider(
                  height: 1,
                  indent: 68,
                  endIndent: 16,
                  color: AppColors.borderLight,
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _MenuItemData {
  final IconData icon;
  final String title;
  final bool isYellowBg;
  final Widget? trailing;

  _MenuItemData(
    this.icon,
    this.title, {
    this.isYellowBg = false,
    this.trailing,
  });
}
