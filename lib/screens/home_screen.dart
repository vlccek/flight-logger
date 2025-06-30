// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';

class HomeScreen extends StatelessWidget {

  static const routeName = '/home'; // Doporučuji pomlčky pro čitelnost

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      // Přidání draweru
      drawer: AppDrawer(),
      body: Center(
        child: Text('Welcome to the Flight App!'),
      ),
    );
  }
}