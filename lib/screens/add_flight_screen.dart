// lib/screens/add_flight_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geodesy/geodesy.dart';
import 'package:maplibre/maplibre.dart';
import 'package:intl/intl.dart'; // For date formatting

// --- Application-specific imports ---
import '../database/database.dart'; // Provides access to data classes like Airport
import '../services/drift_service.dart';
import '../services/route_calculation_service.dart';
import '../widgets/app_drawer.dart'; // Your custom AppDrawer

class AddFlightScreen extends StatefulWidget {
  const AddFlightScreen({super.key});

  // Route name for navigation
  static const routeName = '/add-flight';

  @override
  State<AddFlightScreen> createState() => _AddFlightScreenState();
}

class _AddFlightScreenState extends State<AddFlightScreen> {
  // A key to identify and validate the form
  final _formKey = GlobalKey<FormState>();

  // --- Controllers for Text Fields ---
  final _dateController = TextEditingController();
  final _departureController = TextEditingController();
  final _arrivalController = TextEditingController();
  final _durationController = TextEditingController();

  // --- State Variables ---
  List<Airport> _allAirports = [];
  Airport? _selectedDeparture;
  Airport? _selectedArrival;
  DateTime? _selectedFlightDate;
  Duration _selectedFlightDuration = const Duration();

  bool _isLoading = true;
  bool _isSaving = false;

  // --- Service Instances ---
  final _dbService = DriftService.instance;
  final _routeCalculator = RouteCalculationService();
  final _geodesy = Geodesy();

  @override
  void initState() {
    super.initState();
    _loadAirports();
  }

  @override
  void dispose() {
    // Clean up the controllers when the widget is disposed to prevent memory leaks.
    _dateController.dispose();
    _departureController.dispose();
    _arrivalController.dispose();
    super.dispose();
  }

  /// Fetches the list of all airports from the database when the widget is first created.
  Future<void> _loadAirports() async {
    final airports = await _dbService.getAllAirports();
    if (mounted) {
      setState(() {
        _allAirports = airports;
        _isLoading = false;
      });
    }
  }

  /// Shows a date and time picker to the user.
  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedFlightDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate == null || !mounted) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        _selectedFlightDate ?? DateTime.now(),
      ),
    );
    if (pickedTime == null) return;

    setState(() {
      _selectedFlightDate = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
      _dateController.text = DateFormat(
        'yyyy-MM-dd – HH:mm',
      ).format(_selectedFlightDate!);
    });
  }

  /// Handles the form submission, calculates route data, and saves the new flight.
  Future<void> _saveFlight() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (mounted) setState(() => _isSaving = true);

    try {
      final departure = _selectedDeparture!;
      final arrival = _selectedArrival!;

      final startLatLng = LatLng(departure.latitude, departure.longitude);
      final endLatLng = LatLng(arrival.latitude, arrival.longitude);

      final distanceInMeters = _geodesy
          .distanceBetweenTwoGeoPoints(startLatLng, endLatLng)
          .toInt();
      final pointCount = _routeCalculator.calculatePointsForRoute(
        distanceInMeters,
      );
      final routePositions = _routeCalculator.generateRoutePositions(
        startLatLng,
        endLatLng,
        pointCount,
      );

      final routePathForDb = routePositions
          .where((p) => p.length >= 2 && p[0] != null && p[1] != null)
          .map(
            (p) => RoutePoint(
              latitude: p[1]!.toDouble(),
              longitude: p[0]!.toDouble(),
            ),
          )
          .toList();

      final newFlight = FlightsCompanion.insert(
        departureAirportId: departure.id,
        arrivalAirportId: arrival.id,
        flightDate: _selectedFlightDate!,
        flightDuration: _selectedFlightDuration,
        distance: distanceInMeters,
        routePath: routePathForDb,
      );

      await _dbService.saveFlight(newFlight);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Flight saved successfully!')),
        );
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save flight: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add a New Flight')),
      drawer: AppDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      // --- Autocomplete for Departure Airport ---
                      Autocomplete<Airport>(
                        displayStringForOption: (Airport option) =>
                            '${option.name} (${option.icaoCode})',
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty) {
                            return const Iterable<Airport>.empty();
                          }
                          final query = textEditingValue.text.toLowerCase();
                          return _allAirports.where((Airport airport) {
                            return airport.name.toLowerCase().contains(query) ||
                                airport.icaoCode.toLowerCase().contains(query);
                          });
                        },
                        onSelected: (Airport selection) {
                          setState(() => _selectedDeparture = selection);
                          _departureController.text =
                              '${selection.name} (${selection.icaoCode})';
                        },
                        fieldViewBuilder:
                            (context, controller, focusNode, onFieldSubmitted) {
                              _departureController.text =
                                  _selectedDeparture != null
                                  ? '${_selectedDeparture!.name} (${_selectedDeparture!.icaoCode})'
                                  : '';
                              return TextFormField(
                                controller: controller,
                                focusNode: focusNode,
                                decoration: const InputDecoration(
                                  labelText: 'Departure Airport',
                                  hintText: 'Search by name or ICAO code',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (_selectedDeparture == null ||
                                      value!.isEmpty) {
                                    return 'Please select a valid departure airport.';
                                  }
                                  return null;
                                },
                              );
                            },
                      ),
                      const SizedBox(height: 20),
                      // --- Autocomplete for Arrival Airport ---
                      Autocomplete<Airport>(
                        displayStringForOption: (Airport option) =>
                            '${option.name} (${option.icaoCode})',
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty) {
                            return const Iterable<Airport>.empty();
                          }
                          final query = textEditingValue.text.toLowerCase();
                          return _allAirports.where((Airport airport) {
                            return airport.name.toLowerCase().contains(query) ||
                                airport.icaoCode.toLowerCase().contains(query);
                          });
                        },
                        onSelected: (Airport selection) {
                          setState(() => _selectedArrival = selection);
                          _arrivalController.text =
                              '${selection.name} (${selection.icaoCode})';
                        },
                        fieldViewBuilder:
                            (context, controller, focusNode, onFieldSubmitted) {
                              _arrivalController.text = _selectedArrival != null
                                  ? '${_selectedArrival!.name} (${_selectedArrival!.icaoCode})'
                                  : '';
                              return TextFormField(
                                controller: controller,
                                focusNode: focusNode,
                                decoration: const InputDecoration(
                                  labelText: 'Arrival Airport',
                                  hintText: 'Search by name or ICAO code',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (_selectedArrival == null ||
                                      value!.isEmpty) {
                                    return 'Please select a valid arrival airport.';
                                  }
                                  if (_selectedDeparture != null &&
                                      _selectedArrival?.id ==
                                          _selectedDeparture?.id) {
                                    return 'Arrival airport cannot be the same as departure.';
                                  }
                                  return null;
                                },
                              );
                            },
                      ),
                      const SizedBox(height: 20),
                      // --- Date and Time Picker Field ---
                      TextFormField(
                        controller: _dateController,
                        decoration: const InputDecoration(
                          labelText: 'Flight Date & Time',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        readOnly: true,
                        onTap: () => _selectDateTime(context),
                        validator: (value) {
                          if (_selectedFlightDate == null) {
                            return 'Please select a date and time.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      // --- Flight Duration Input ---
                      TextFormField(
                        controller: _durationController,
                        decoration: const InputDecoration(
                          labelText: 'Flight Duration',
                          hintText: 'hh:mm',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.timer_outlined),
                        ),
                        keyboardType: TextInputType.datetime,
                        // Input formatters to enforce the hh:mm format
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9:]')),
                          LengthLimitingTextInputFormatter(5),
                          _TimeTextInputFormatter(),
                        ],
                      ),
                      const SizedBox(height: 40),
                      Center(
                        child: _isSaving
                            ? const CircularProgressIndicator()
                            : ElevatedButton.icon(
                                icon: const Icon(Icons.save_alt_outlined),
                                onPressed: _saveFlight,
                                label: const Text('Save Flight'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 12,
                                  ),
                                  textStyle: const TextStyle(fontSize: 16),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class _TimeTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // If the new value is shorter than the old one, let the user delete freely.
    if (newValue.text.length < oldValue.text.length) {
      return newValue;
    }

    // If the user has typed two digits and the text doesn't already have a colon, add one.
    if (newValue.text.length == 2 && !oldValue.text.contains(':')) {
      return TextEditingValue(
        text: '${newValue.text}:',
        selection: TextSelection.collapsed(offset: newValue.selection.end + 1),
      );
    }
    return newValue;
  }
}
