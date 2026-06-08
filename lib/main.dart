import 'package:flutter/material.dart';
import 'dashboard_screen.dart';

void main() {
  runApp(const CarveplusApp());
}

class CarveplusApp extends StatelessWidget {
  const CarveplusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DashboardScreen(),
    );
  }
}
