// misslog/lib/main.dart
import 'package:flutter/material.dart';
import 'home.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(
    ProviderScope(
      child: const MyApp()
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Misslog',
      themeMode: ThemeMode.system,
      home: const Home(selectedNumber: 0),
    );
  }
}