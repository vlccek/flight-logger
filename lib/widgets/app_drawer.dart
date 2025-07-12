// lib/widgets/app_drawer.dart
import 'package:flutter/material.dart';
import 'package:flight_logger/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import '../screens/add_flight_screen.dart';
import '../screens/flight_import_screen.dart';
import '../screens/list_flights.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          AppBar(
            title: const Text('Menu'),
            automaticallyImplyLeading: false, // Nechceme zde tlačítko zpět
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              // Přejde na domovskou obrazovku
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.flight),
            title: const Text('Add Flight'),
            onTap: () {
              Navigator.of(
                context,
              ).pushReplacementNamed(AddFlightScreen.routeName);
            },
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('List Flights'),
            onTap: () {
              Navigator.of(
                context,
              ).pushReplacementNamed(FlightListScreen.routeName);
            },
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('Flight radar 24 import'),
            onTap: () {
              Navigator.of(
                context,
              ).pushReplacementNamed(FlightImportScreen.routeName);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/settings');
            },
          ),
        ],
      ),
    );
  }
}
