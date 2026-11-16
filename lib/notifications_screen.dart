import 'package:flutter/material.dart';
import 'app_colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int _selectedTab = 0; // 0: Todas, 1: Não lidas
  bool _hasUnread = true;

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
                  'Notificações',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.black),
                ),
                if (_hasUnread)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.accentYellow,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '2',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.darkNavy),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Fique por dentro dos seus cuidados.',
              style: TextStyle(fontSize: 14, color: AppColors.slateText),
            ),
            const SizedBox(height: 20),

            // Abas
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.cardFill,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  _buildTab(0, 'Todas'),
                  _buildTab(1, _hasUnread ? 'Não lidas (2)' : 'Não lidas (0)'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Hoje
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Hoje', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                GestureDetector(
                  onTap: () => setState(() => _hasUnread = false),
                  child: const Text(
                    'Marcar todas como lidas',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primaryBlue),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            _buildNotificationCard(
              icon: Icons.event_available_outlined,
              title: 'Sua consulta está chegando',
              description: 'Dr. Rafael Lima · Cardiologista\nAmanhã, 17 nov, às 16:30.',
              time: 'Há 10 min',
              isUnread: _hasUnread,
            ),
            const SizedBox(height: 12),
            _buildNotificationCard(
              icon: Icons.check_box_outlined,
              title: 'Consulta confirmada',
              description: 'Seu agendamento na Clínica Vida\nestá confirmado. Veja os detalhes.',
              time: 'Há 1 hora',
              isUnread: _hasUnread,
            ),

            if (_selectedTab == 0) ...[
              const SizedBox(height: 24),
              const Text('Ontem', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              _buildNotificationCard(
                icon: Icons.description_outlined,
                title: 'Resultado de exame disponível',
                description: 'Seu resultado já pode ser consultado.\nAcesse para conferir.',
                time: 'Ontem, às 14:20',
                isUnread: false,
              ),
              const SizedBox(height: 12),
              _buildNotificationCard(
                icon: Icons.star_border_rounded,
                title: 'Como foi sua consulta?',
                description: 'Conte como foi seu atendimento.\nSua avaliação faz a diferença.',
                time: 'Ontem, às 10:00',
                isUnread: false,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTab(int index, String label) {
    final bool isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
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

  Widget _buildNotificationCard({
    required IconData icon,
    required String title,
    required String description,
    required String time,
    required bool isUnread,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnread ? AppColors.cardFill : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isUnread ? null : Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isUnread ? Colors.white : AppColors.cardFill,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: isUnread ? AppColors.primaryBlue : AppColors.slateText),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.darkNavy),
                      ),
                    ),
                    if (isUnread)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(color: AppColors.primaryBlue, shape: BoxShape.circle),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(fontSize: 13, color: AppColors.slateText, height: 1.4),
                ),
                const SizedBox(height: 12),
                Text(
                  time,
                  style: const TextStyle(fontSize: 11, color: AppColors.slateText, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}