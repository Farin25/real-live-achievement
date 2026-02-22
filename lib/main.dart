import 'package:flutter/material.dart';
import 'package:real_live_achievments/about.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'licenses.dart';
import 'navbar.dart';

void main () {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
  theme: ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.light,
    ),
  ),
  darkTheme: ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.dark,
    ),
  ),
  home: GoogleBottomBar(),
    );

}

}
