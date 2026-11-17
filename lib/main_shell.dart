import 'package:flutter/material.dart';

import 'custom_bottom_nav.dart';
import 'favorites_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';

class MainShell extends StatefulWidget {
  final Widget homeScreen;
  final int initialIndex;
  final VoidCallback? onSignOut;

  const MainShell({
    super.key,
    required this.homeScreen,
    this.initialIndex = 0,
    this.onSignOut,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      widget.homeScreen,
      const NotificationsScreen(),
      const FavoritesScreen(),
      ProfileScreen(onSignOut: widget.onSignOut),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
