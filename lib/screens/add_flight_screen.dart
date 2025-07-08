import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:geodesy/geodesy.dart';
import 'package:intl/intl.dart';

// --- Application-specific imports ---
import '../database/database.dart';
import '../services/drift_service.dart';
import '../services/route_calculation_service.dart';
import '../widgets/app_drawer.dart';

class AddFlightScreen extends StatefulWidget {
  const AddFlightScreen({super.key, this.flightToEdit});

  static const routeName = '/add-flight';

  final FlightWithDetails? flightToEdit;

  @override
  State<AddFlightScreen> createState() => _AddFlightScreenState();
}

class _AddFlightScreenState extends State<AddFlightScreen> {
  final _formKey = GlobalKey<FormState>();

  // --- Controllers for Text Fields ---
  final _flightNumberController = TextEditingController();
  final _dateController = TextEditingController();
  final _departureController = TextEditingController();
  final _arrivalController = TextEditingController();
  final _durationController = TextEditingController();
  final _airplaneTypeController = TextEditingController();
  final _registrationController = TextEditingController();
  final _seatController = TextEditingController();

  // --- State Variables ---
  DateTime? _selectedFlightDate;
  Airport? _selectedDeparture;
  Airport? _selectedArrival;
  Duration _flightDuration = Duration.zero;
  SeatType? _selectedSeatType;

  FlightWithDetails? _flightToEdit;

  // --- Loading/State Management ---
  bool _isSaving = false;

  // --- Service Instances ---
  final _dbService = DriftService.instance;
  final _routeCalculator = RouteCalculationService();
  final _geodesy = Geodesy();

  @override
  void initState() {
    super.initState();
    _flightToEdit = widget.flightToEdit;

    if (_flightToEdit != null) {
      final flight = _flightToEdit!.flight;
      final departure = _flightToEdit!.departureAirport;
      final arrival = _flightToEdit!.arrivalAirport;

      _flightNumberController.text = flight.flightNumber ?? '';
      _selectedFlightDate = flight.flightDate;
      _dateController.text = DateFormat('yyyy-MM-dd').format(flight.flightDate);
      _selectedDeparture = departure;
      _departureController.text = '${departure.name} (${departure.icaoCode})';
      _selectedArrival = arrival;
      _arrivalController.text = '${arrival.name} (${arrival.icaoCode})';
      _flightDuration = flight.flightDuration;
      _durationController.text = '${flight.flightDuration.inHours.toString().padLeft(2, '0')}:${flight.flightDuration.inMinutes.remainder(60).toString().padLeft(2, '0')}';
      _airplaneTypeController.text = flight.airplaneType ?? '';
      _registrationController.text = flight.registration ?? '';
      _seatController.text = flight.seat ?? '';
      _selectedSeatType = flight.seatType;
    }
  }

  @override
  void dispose() {
    _flightNumberController.dispose();
    _dateController.dispose();
    _departureController.dispose();
    _arrivalController.dispose();
    _durationController.dispose();
    _airplaneTypeController.dispose();
    _registrationController.dispose();
    _seatController.dispose();
    super.dispose();
  }

  /// Shows a date picker to the user.
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedFlightDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _selectedFlightDate) {
      setState(() {
        _selectedFlightDate = pickedDate;
        _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedFlightDate!);
      });
    }
  }

  /// Saves the final flight data to the database.
  Future<void> _saveFlight() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final departure = _selectedDeparture!;
      final arrival = _selectedArrival!;

      final durationParts = _durationController.text.split(':').map(int.parse).toList();
      _flightDuration = Duration(hours: durationParts[0], minutes: durationParts[1]);

      final distanceInMeters = _geodesy.distanceBetweenTwoGeoPoints(
        LatLng(departure.latitude, departure.longitude),
        LatLng(arrival.latitude, arrival.longitude),
      ).toInt();
      final pointCount = _routeCalculator.calculatePointsForRoute(distanceInMeters);
      final routePositions = _routeCalculator.generateRoutePositions(
        LatLng(departure.latitude, departure.longitude),
        LatLng(arrival.latitude, arrival.longitude),
        pointCount,
      );
      final routePathForDb = routePositions
          .where((p) => p.length >= 2 && p[0] != null && p[1] != null)
          .map((p) => RoutePoint(latitude: p[1]!.toDouble(), longitude: p[0]!.toDouble()))
          .toList();

      final FlightsCompanion flightCompanion = FlightsCompanion(
        id: _flightToEdit != null ? Value(_flightToEdit!.flight.id) : const Value.absent(),
        departureAirportId: Value(departure.id),
        arrivalAirportId: Value(arrival.id),
        flightDate: Value(_selectedFlightDate!),
        flightDuration: Value(_flightDuration),
        distance: Value(distanceInMeters),
        routePath: Value(routePathForDb),
        flightNumber: Value(_flightNumberController.text),
        airplaneType: Value(_airplaneTypeController.text),
        registration: Value(_registrationController.text),
        seat: Value(_seatController.text),
        seatType: Value(_selectedSeatType),
      );

      await _dbService.saveFlight(flightCompanion);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Flight saved successfully!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save flight: $e'))
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<Airport?> _searchAirport(BuildContext context) async {
    final airports = await _dbService.getAllAirports();
    return showSearch<Airport?>(
      context: context,
      delegate: AirportSearchDelegate(airports),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Flight Manually')),
      drawer: AppDrawer(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _flightNumberController,
                decoration: const InputDecoration(
                  labelText: 'Flight Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: 'Flight Date',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () => _selectDate(context),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _departureController,
                decoration: const InputDecoration(
                  labelText: 'Departure Airport',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.search),
                ),
                readOnly: true,
                onTap: () async {
                  final airport = await _searchAirport(context);
                  if (airport != null) {
                    setState(() {
                      _selectedDeparture = airport;
                      _departureController.text = '${airport.name} (${airport.icaoCode})';
                    });
                  }
                },
                validator: (value) => value!.isEmpty ? 'Departure is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _arrivalController,
                decoration: const InputDecoration(
                  labelText: 'Arrival Airport',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.search),
                ),
                readOnly: true,
                onTap: () async {
                  final airport = await _searchAirport(context);
                  if (airport != null) {
                    setState(() {
                      _selectedArrival = airport;
                      _arrivalController.text = '${airport.name} (${airport.icaoCode})';
                    });
                  }
                },
                validator: (value) => value!.isEmpty ? 'Arrival is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(
                  labelText: 'Flight Duration (hh:mm)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Duration is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _airplaneTypeController,
                decoration: const InputDecoration(
                  labelText: 'Airplane Type',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _registrationController,
                decoration: const InputDecoration(
                  labelText: 'Registration',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _seatController,
                      decoration: const InputDecoration(
                        labelText: 'Seat',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<SeatType>(
                      value: _selectedSeatType,
                      decoration: const InputDecoration(
                        labelText: 'Seat Type',
                        border: OutlineInputBorder(),
                      ),
                      items: SeatType.values.map((SeatType type) {
                        return DropdownMenuItem<SeatType>(
                          value: type,
                          child: Text(type.toString().split('.').last),
                        );
                      }).toList(),
                      onChanged: (SeatType? newValue) {
                        setState(() {
                          _selectedSeatType = newValue;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              if (_isSaving)
                const Center(child: CircularProgressIndicator())
              else
                ElevatedButton.icon(
                  icon: const Icon(Icons.save_alt_outlined),
                  onPressed: _saveFlight,
                  label: const Text('Save Flight'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class AirportSearchDelegate extends SearchDelegate<Airport?> {
  final List<Airport> airports;

  AirportSearchDelegate(this.airports);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [IconButton(icon: Icon(Icons.clear), onPressed: () => query = '')];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = airports.where((a) => a.name.toLowerCase().contains(query.toLowerCase()) || a.icaoCode.toLowerCase().contains(query.toLowerCase()));
    return ListView(
      children: results.map((a) => ListTile(
        title: Text('${a.name} (${a.icaoCode})'),
        onTap: () => close(context, a),
      )).toList(),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final results = airports.where((a) => a.name.toLowerCase().contains(query.toLowerCase()) || a.icaoCode.toLowerCase().contains(query.toLowerCase()));
    return ListView(
      children: results.map((a) => ListTile(
        title: Text('${a.name} (${a.icaoCode})'),
        onTap: () => close(context, a),
      )).toList(),
    );
  }
}
