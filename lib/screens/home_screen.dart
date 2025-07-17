// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flight_logger/services/sync_service.dart';
import '../widgets/app_drawer.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SyncService _syncService = SyncService();

  void _synchronize() async {
    try {
      await _syncService.synchronizeFlights();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Synchronization complete!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Synchronization failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: _synchronize,
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: const Center(
        child: Text('Welcome to the Flight App!'),
      ),
    );
  }
}
