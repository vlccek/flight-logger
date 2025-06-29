// lib/main.dart
import 'package:flutter/material.dart';
import 'package:maplibre/maplibre.dart';

// Import all your screens
import 'screens/map_screen.dart';
import 'screens/add_flight_screen.dart';

Future<void> main() async {
  // Ensure Flutter is ready before we do async work.
  WidgetsFlutterBinding.ensureInitialized();


  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flight Logger',
      // Set the home screen of the app
      initialRoute: LayersPolylinePage.routeName,
      theme: ThemeData(colorSchemeSeed: Colors.blue),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.blue,
      ),
      // Define all the routes your app can navigate to.
      routes: {
        // MapScreen.routeName: (context) => const MapScreen(),
        AddFlightScreen.routeName: (context) => const AddFlightScreen(),
        LayersPolylinePage.routeName: (context) => const LayersPolylinePage(),
      },
    );
  }
}