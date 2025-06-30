// lib/widgets/app_drawer.dart
import 'package:flight_logger/screens/home_screen.dart';
import 'package:flutter/material.dart';
import '../screens/add_flight_screen.dart';
import '../screens/map_screen.dart';
import '../screens/flight_import_screen.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          AppBar(
            title: Text('Menu'),
            automaticallyImplyLeading: false, // Nechceme zde tlačítko zpět
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () {
              // Přejde na domovskou obrazovku
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.flight),
            title: Text('Add Flight'),
            onTap: () {
              Navigator.of(
                context,
              ).pushReplacementNamed(AddFlightScreen.routeName);
            },
          ),
          ListTile(
            leading: Icon(Icons.list),
            title: Text('List Flights'),
            onTap: () {
              Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
            },
          ),
          ListTile(
            leading: Icon(Icons.list),
            title: Text('Flight radar 24 import'),
            onTap: () {
              Navigator.of(
                context,
              ).pushReplacementNamed(FlightImportScreen.routeName);
            },
          ),
        ],
      ),
    );
  }
}
