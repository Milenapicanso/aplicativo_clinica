import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestException;

import 'app_colors.dart';
import 'supabase_client.dart';
import 'supabase_repository.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int _selectedTab = 0; // 0: Todas, 1: Não lidas
  late Future<List<Map<String, dynamic>>> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = loadNotifications();
  }

  Future<void> _markRead(String id) async {
    try {
      await supabase.from('notificacoes').update({'lida': true}).eq('id', id);
      if (mounted) setState(() => _notifications = loadNotifications());
    } on PostgrestException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    }
  }

  Future<void> _markAllRead(List<Map<String, dynamic>> rows) async {
    if (!rows.any((row) => row['lida'] != true)) return;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;
    try {
      await supabase
          .from('notificacoes')
          .update({'lida': true})
          .eq('paciente_id', userId)
          .eq('lida', false);
      if (mounted) setState(() => _notifications = loadNotifications());
    } on PostgrestException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _notifications,
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
                'Não foi possível carregar notificações: ${snapshot.error}',
              ),
            ),
          );
        }
        return _buildNotifications(context, snapshot.data ?? const []);
      },
    );
  }

  Widget _buildNotifications(
    BuildContext context,
    List<Map<String, dynamic>> rows,
  ) {
    final unread = rows.where((row) => row['lida'] != true).length;
    final visibleRows = _selectedTab == 0
        ? rows
        : rows.where((row) => row['lida'] != true).toList();

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
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                if (unread > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accentYellow,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$unread',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.darkNavy,
                      ),
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
                  _buildTab(0, 'Todas (${rows.length})'),
                  _buildTab(1, 'Não lidas ($unread)'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Hoje
            if (unread > 0)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => _markAllRead(rows),
                  child: const Text('Marcar todas como lidas'),
                ),
              ),
            if (visibleRows.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: Text('Nenhuma notificação por enquanto.')),
              )
            else
              for (var index = 0; index < visibleRows.length; index++) ...[
                if (index == 0 ||
                    _dateGroup(visibleRows[index - 1]['criada_em'] as String) !=
                        _dateGroup(visibleRows[index]['criada_em'] as String))
                  Text(
                    _dateGroup(visibleRows[index]['criada_em'] as String),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                const SizedBox(height: 12),
                _buildNotificationCard(
                  icon: _iconFor(visibleRows[index]['tipo'] as String? ?? ''),
                  title:
                      visibleRows[index]['titulo'] as String? ?? 'Notificação',
                  description: visibleRows[index]['mensagem'] as String? ?? '',
                  time: _timeLabel(visibleRows[index]['criada_em'] as String),
                  isUnread: visibleRows[index]['lida'] != true,
                  onTap: () => _markRead(visibleRows[index]['id'] as String),
                ),
                const SizedBox(height: 12),
              ],
          ],
        ),
      ),
    );
  }

  IconData _iconFor(String type) => switch (type) {
    'consulta' => Icons.event_available_outlined,
    'exame' => Icons.description_outlined,
    _ => Icons.notifications_none_rounded,
  };

  String _dateGroup(String value) {
    final date = DateTime.parse(value).toLocal();
    final now = DateTime.now();
    final days = DateTime(
      now.year,
      now.month,
      now.day,
    ).difference(DateTime(date.year, date.month, date.day)).inDays;
    if (days == 0) return 'Hoje';
    if (days == 1) return 'Ontem';
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _timeLabel(String value) {
    final date = DateTime.parse(value).toLocal();
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')} · '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
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
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
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
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
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
              child: Icon(
                icon,
                color: isUnread ? AppColors.primaryBlue : AppColors.slateText,
              ),
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
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkNavy,
                          ),
                        ),
                      ),
                      if (isUnread)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryBlue,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.slateText,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.slateText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
