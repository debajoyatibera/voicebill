import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

// Passed in at build/run time with:
// flutter run --dart-define=GEMINI_API_KEY=your_key_here
const String geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');

void main() {
  runApp(const VoiceBillApp());
}

class VoiceBillApp extends StatelessWidget {
  const VoiceBillApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VoiceBill',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: geminiApiKey.isEmpty
          ? const _MissingKeyScreen()
          : const HomeScreen(geminiApiKey: geminiApiKey),
    );
  }
}

class _MissingKeyScreen extends StatelessWidget {
  const _MissingKeyScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Padding(
        padding: EdgeInsets.all(24.0),
        child: Center(
          child: Text(
            'Missing Gemini API key.\n\n'
            'Run the app with:\n'
            'flutter run --dart-define=GEMINI_API_KEY=your_key_here',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
