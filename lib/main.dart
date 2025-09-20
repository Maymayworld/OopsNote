// misslog/lib/main.dart
import 'package:flutter/material.dart';
import 'home.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp()
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OopsNote',
      theme: ThemeData(
        textTheme: GoogleFonts.zenKakuGothicNewTextTheme(),
      ),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: Home(selectedNumber: 0),
    );
  }
}