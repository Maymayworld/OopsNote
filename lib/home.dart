// lib/home.dart
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'themes/app_theme.dart';
import 'screens/home/home_screen.dart';
import 'screens/mistake/mistake_screen.dart';
import 'screens/analysis/analysis_screen.dart';
import 'screens/shop/shop_screen.dart';

class Home extends HookConsumerWidget {
  final int selectedNumber;

  const Home({
    super.key,
    this.selectedNumber = 0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = useState<int>(selectedNumber);

    final pages = [
      const HomeScreen(),
      const MistakeListScreen(),
      const AnalysisScreen(),
      const ShopScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFf5f5f5),
      body: pages[currentIndex.value],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex.value,
        backgroundColor: backgroundGray,
        selectedItemColor: primaryBlue,
        unselectedItemColor: secondaryBlue,
        onTap: (index) => currentIndex.value = index,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'ホーム'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.note),
            label: 'ミス集'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: '分析'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shop),
            label: 'ショップ'
          ),
        ]),
    );
  }
}