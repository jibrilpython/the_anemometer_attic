import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:the_anemometer_attic/screens/home_screen.dart';
import 'package:the_anemometer_attic/screens/stats_screen.dart';
import 'package:the_anemometer_attic/screens/showcase_screen.dart';
import 'dart:ui';
import 'package:the_anemometer_attic/utils/const.dart';
import 'package:google_fonts/google_fonts.dart';

class MainNavigation extends ConsumerStatefulWidget {
  const MainNavigation({super.key});

  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends ConsumerState<MainNavigation> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animController;

  final List<Widget> _screens = const [
    HomeScreen(),
    StatsScreen(),
    ShowcaseScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _setIndex(int i) {
    if (i == _currentIndex) return;
    setState(() => _currentIndex = i);
    _animController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      extendBody: true,
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomNav(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      margin: EdgeInsets.only(
        bottom: 24.h, // Removed SafeArea bottom padding offset
        left: 24.w,
        right: 24.w,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(kRadiusPill),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            height: 64.h,
            decoration: BoxDecoration(
              color: kPrimaryText.withAlpha(220), // Darker liquid dark look
              borderRadius: BorderRadius.circular(kRadiusPill),
              border: Border.all(
                color: Colors.white.withAlpha(20),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildNavItem(0, Icons.layers_outlined, 'Attic'),
                _buildNavItem(1, Icons.analytics_outlined, 'Logbook'),
                _buildNavItem(2, Icons.air_outlined, 'Mine Map'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => _setIndex(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 80.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? kAccentLight : Colors.white.withAlpha(140),
              size: 22.sp,
            ),
            SizedBox(height: 4.h),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 180),
              style: GoogleFonts.inter(
                color: isSelected ? Colors.white : Colors.white.withAlpha(140),
                fontSize: 10.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                letterSpacing: 0.2,
              ),
              child: Text(label),
            ),
            SizedBox(height: 4.h),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isSelected ? 24.w : 0,
              height: 3.h,
              decoration: BoxDecoration(
                color: kAccent,
                borderRadius: BorderRadius.circular(kRadiusPill),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
