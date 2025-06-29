// lib/main.dart
import 'package:flutter/material.dart';
import './screens/add_flight_screen.dart';
import './screens/home_screen.dart';
import 'screens/map_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flight App',
      // Nastavení úvodní obrazovky
      initialRoute: '/',
      // Definice všech dostupných cest v aplikaci
      routes: {
        '/': (ctx) => LayersPolylinePage(), // Vaše domovská obrazovka
        AddFlightScreen.routeName: (ctx) => AddFlightScreen(),
      },
    );
  }
}
