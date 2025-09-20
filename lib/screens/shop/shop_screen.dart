// lib/screens/shop/shop_screen.dart
import 'package:flutter/material.dart';
import 'package:misslog/themes/app_theme.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ShopScreen extends HookConsumerWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: backgroundGray,
      body: Center(
        child: Text('Shop Screen'),
      ),
    );
  }
}