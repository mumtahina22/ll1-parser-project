import 'package:flutter/material.dart';
import 'package:ll1_parser/parser_screen.dart';

void main() {
  runApp(const ParserVisualizerApp());
}

class ParserVisualizerApp extends StatelessWidget {
  const ParserVisualizerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Parser Visualizer',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B0F19), // Deeper Midnight Black/Blue
        primaryColor: const Color(0xFF3B82F6), // Vibrant Blue
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF3B82F6),
          secondary: Color(0xFF00E5FF), // Cyber Neon Cyan
          surface: Color(0xFF161E2E), // Elevated Dark Blue Surface
        ),
        fontFamily: 'Inter', // Try to default to a modern font if available in system
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      home: const ParserScreen(),
    );
  }
}