import 'package:flutter/material.dart';
import '../main.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Check for route arguments to handle preset loading
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    
    // For now, we'll use the existing MyHomePage as the home screen content
    // This maintains all existing functionality while adding navigation
    return MyHomePage(routeArguments: args);
  }
}