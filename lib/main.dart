// misslog/lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 環境変数ファイルを読み込み
  await dotenv.load(fileName: ".env");
  
  // Supabaseを初期化
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  
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