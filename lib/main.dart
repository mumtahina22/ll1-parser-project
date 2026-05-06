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
        useMaterial3: true, // Enables Flutter's modern design system
        brightness: Brightness.dark,
        // Deep Midnight Blue background
        scaffoldBackgroundColor: const Color(0xFF0F172A), 
        primaryColor: const Color(0xFF3B82F6), 
        colorScheme: const ColorScheme.dark(
          // Sleek modern blue for primary actions
          primary: Color(0xFF3B82F6), 
          // Emerald/Teal for secondary accents (looks great against midnight blue)
          secondary: Color(0xFF2DD4BF), 
          // Slightly lighter midnight blue for elevated surfaces (text boxes, tables)
          surface: Color(0xFF1E293B), 
        ),
        // Removed the monospace font so it uses the clean default sans-serif
      ),
      home: const ParserScreen(),
    );
  }
}