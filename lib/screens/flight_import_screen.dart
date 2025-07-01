// lib/screens/flight_import_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/drift_service.dart'; // Make sure the path is correct
import '../widgets/app_drawer.dart';

class FlightImportScreen extends StatefulWidget {
  const FlightImportScreen({super.key});

  static const routeName = '/fr-import';

  @override
  State<FlightImportScreen> createState() => _FlightImportScreenState();
}

class _FlightImportScreenState extends State<FlightImportScreen> {
  bool _isLoading = false;
  String _statusMessage = 'Import your flights from a Flightradar24 CSV file.';

  Future<void> _importCsv() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Checking permissions...';
    });

    try {
      setState(() => _statusMessage = 'Please select your CSV file...');

      // 2. Let the user pick a file.
      final result = await FilePicker.platform.pickFiles(
        withData: true,
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result == null || result.files.single.bytes == null) {
        setState(() => _statusMessage = 'File picking cancelled.');
        return;
      }

      setState(() => _statusMessage = 'File selected. Reading content...');
      final fileBytes = result.files.single.bytes!;
      final csvString = utf8.decode(fileBytes);

      setState(() => _statusMessage = 'Parsing and importing flights...');
      final importedCount = await DriftService.instance.importFlightsFromCsv(
        csvString,
      );

      setState(() {
        _statusMessage =
            'Import complete! Successfully imported $importedCount flights.';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'An error occurred during import: $e';
      });
    } finally {
      // Ensure isLoading is always set to false at the end.
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(title: const Text('Import Flights')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.cloud_upload_outlined,
                size: 80,
                color: Colors.grey,
              ),
              const SizedBox(height: 24),
              Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 32),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton.icon(
                  icon: const Icon(Icons.description_outlined),
                  label: const Text('Select CSV File'),
                  onPressed: _importCsv,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
