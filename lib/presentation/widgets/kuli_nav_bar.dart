import 'package:chat_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class KuliNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const KuliNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      decoration: BoxDecoration(
        color: KuliColors.surface,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _NavBarItem(
            icon: Icons.home_filled,
            isActive: currentIndex == 0,
            onTap: () => onTap(0),
          ),
          _NavBarItem(
            icon: Icons.explore_outlined,
            isActive: currentIndex == 1,
            onTap: () => onTap(1),
          ),
          _MagicButton(onTap: () => onTap(2)),
          _NavBarItem(
            icon: Icons.chat_bubble_outline,
            isActive: currentIndex == 3,
            onTap: () => onTap(3),
          ),
          _NavBarItem(
            icon: Icons.person_outline,
            isActive: currentIndex == 4,
            onTap: () => onTap(4),
          ),
        ],
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        icon,
        color: isActive ? KuliColors.primary : KuliColors.textSecondary,
        size: 28,
      ),
    );
  }
}

class _MagicButton extends StatelessWidget {
  final VoidCallback onTap;

  const _MagicButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [KuliColors.primary, KuliColors.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Icon(
          Icons.auto_awesome,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}
