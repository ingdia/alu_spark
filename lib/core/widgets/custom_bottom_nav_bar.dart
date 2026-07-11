import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavBar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        // Pill-shaped Bottom Bar
        Container(
          height: 75,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.darkBlueLight.withOpacity(0.85),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: AppColors.borderGlass, width: 1.5),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_rounded, 'Discover'),
              _buildNavItem(1, Icons.search_rounded, 'Search'),
              const SizedBox(width: 60), // Space for FAB
              _buildNavItem(3, Icons.chat_bubble_rounded, 'Messages'),
              _buildNavItem(4, Icons.person_rounded, 'Profile'),
            ],
          ),
        ),
        // Center Docked FAB
        Positioned(
          top: 0,
          child: GestureDetector(
            onTap: () => onTap(2),
            child: Container(
              width: 60, height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle, gradient: AppColors.redGradient,
                boxShadow: [BoxShadow(color: AppColors.darkRed.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8))],
              ),
              child: const Icon(Icons.add_rounded, color: AppColors.white, size: 32),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final bool isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? AppColors.darkRed : AppColors.textSecondary, size: 26),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 10, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400, color: isSelected ? AppColors.darkRed : AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}