import 'package:flutter/material.dart';
import 'screens/map_screen.dart';

void main() {
  runApp(const StreetMapApp());
}

class StreetMapApp extends StatelessWidget {
  const StreetMapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Taiwan Cafe Map',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        useMaterial3: true,
      ),
      home: const MapScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}