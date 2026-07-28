import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

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
      home: const HomeScreen(),
    );
  }
}
