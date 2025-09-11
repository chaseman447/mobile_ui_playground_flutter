import 'package:flutter/material.dart';
import '../main.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // For now, we'll use the existing MyHomePage as the home screen content
    // This maintains all existing functionality while adding navigation
    return const MyHomePage();
  }
}