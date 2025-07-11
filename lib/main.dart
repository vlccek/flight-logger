// lib/main.dart
import 'package:flight_logger/screens/list_flights.dart';

import 'package:flutter/material.dart';
import './screens/add_flight_screen.dart';
import './screens/flight_import_screen.dart';
import 'screens/map_screen.dart';
import 'services/drift_service.dart';
import 'utils/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  setupLogger();
  await _runInitialSetup();


  runApp(MyApp());
}

Future<void> _runInitialSetup() async {
  // 1. Check the database directly to see if any airports exist.
  final airportCount = await DriftService.instance.countAirports();

  // 2. If the database is empty, proceed with the one-time import.
  if (airportCount == 0) {
    logDebug('Database is empty. Starting one-time airport data import...');

    // The URL where your JSON file is hosted.
    const String airportDataUrl =
        'https://raw.githubusercontent.com/mwgg/Airports/master/airports.json';

    try {
      // Call the import function from our service.
      await DriftService.instance.importAirportsFromUrl(airportDataUrl);

      DriftService.instance.seedFlightsWithTestData();

      logDebug('One-time import completed successfully.');
    } catch (e) {
      // If the import fails (e.g., no internet connection on first launch),
      // the database will remain empty, and the app will try again on the next launch.
      logDebug('One-time import failed: $e');
    }
  } else {
    // If airports already exist, do nothing.
    logDebug(
      'Airport data already exists in the database ($airportCount entries). Skipping setup.',
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flight App',
      initialRoute: '/',
      routes: {
        '/': (ctx) => LayersPolylinePage(), // Vaše domovská obrazovka
        AddFlightScreen.routeName: (ctx) => AddFlightScreen(),
        FlightImportScreen.routeName: (ctx) => FlightImportScreen(),
        FlightListScreen.routeName: (ctx) => FlightListScreen(),
      },
    );
  }
}
