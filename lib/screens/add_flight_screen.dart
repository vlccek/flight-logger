import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:geodesy/geodesy.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:xml/xml.dart'; // Added XML import

// --- Application-specific imports ---
import '../database/database.dart';
import '../services/drift_service.dart'; // Import for FlightWithDetails and DriftService
import '../services/route_calculation_service.dart'; // Import for RouteCalculationService
import '../widgets/app_drawer.dart'; // Import for AppDrawer
import '../utils/logger.dart'; // Import for logger

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
  Duration? _flightDuration; // Made nullable
  SeatType? _selectedSeatType;
  FlightClass? _selectedFlightClass;
  FlightReason? _selectedFlightReason;
  FilePickerResult? _kmlFileResult;

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
      _selectedFlightClass = flight.flightClass;
      _selectedFlightReason = flight.flightReason;
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
        _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedFlightDate!); // Safe due to null check above
      });
    }
  }

  Future<void> _pickKmlFile() async {
    // Add a small delay to avoid the DOM element assertion error on web
    await Future.delayed(const Duration(milliseconds: 100));

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      withData: true,
      type: FileType.any,
    );

    if (result != null) {
      logger.info('KML file picked: ${result.files.single.name}');
      logger.info('KML file bytes length: ${result.files.single.bytes?.length ?? 0}');
      setState(() {
        _kmlFileResult = result;
      });
    } else {
      logger.warning('KML file picking cancelled.');
    }
  }

  List<RoutePoint> _parseKml(String kmlContent, Airport departureAirport, Airport arrivalAirport) {
    logger.info('Parsing KML content. Content length: ${kmlContent.length}');
    final document = XmlDocument.parse(kmlContent);
    final List<RoutePoint> routePoints = [];
    DateTime? startTime;
    DateTime? endTime;

    // Add departure airport as the first point
    routePoints.add(RoutePoint(
      latitude: departureAirport.latitude,
      longitude: departureAirport.longitude,
      altitude: 0,
    ));

    // First, try to find gx:Track elements, common in flight data
    final gxTracks = document.findAllElements('gx:Track');
    if (gxTracks.isNotEmpty) {
      logger.info('Found ${gxTracks.length} <gx:Track> element(s). Parsing coordinates...');
      for (var track in gxTracks) {
        final gxCoords = track.findElements('gx:coord');
        final whenElements = track.findElements('when');

        logger.info('  Processing track with ${gxCoords.length} gx:coord elements and ${whenElements.length} when elements.');

        for (int i = 0; i < gxCoords.length; i++) {
          final coord = gxCoords.elementAt(i);
          final parts = coord.innerText.trim().split(' ');

          if (parts.length >= 3) {
            final longitude = double.tryParse(parts[0]);
            final latitude = double.tryParse(parts[1]);
            final altitude = double.tryParse(parts[2]);

            if (longitude != null && latitude != null && altitude != null) {
              routePoints.add(RoutePoint(latitude: latitude, longitude: longitude, altitude: altitude));
              if (routePoints.length % 100 == 0) {
                logger.info('    Parsed point ${routePoints.length}: Lat: $latitude, Lon: $longitude, Alt: $altitude');
              }

              if (i < whenElements.length) {
                final whenString = whenElements.elementAt(i).innerText.trim();
                final timestamp = DateTime.tryParse(whenString);
                if (timestamp != null) {
                  if (startTime == null || timestamp.isBefore(startTime)) {
                    startTime = timestamp;
                  }
                  if (endTime == null || timestamp.isAfter(endTime)) {
                    endTime = timestamp;
                  }
                }
              }
            }
          } else {
            logger.warning('    Skipping gx:coord due to insufficient parts: ${coord.innerText}');
          }
        }
      }
    } else {
      // If no gx:Track, look for standard LineString coordinates
      logger.info('No <gx:Track> found. Searching for <LineString><coordinates>...');
      final coordinatesElements = document.findAllElements('coordinates');
      if (coordinatesElements.isNotEmpty) {
        logger.info('Found ${coordinatesElements.length} <coordinates> element(s).');
        for (var coords in coordinatesElements) {
          final lines = coords.innerText.trim().split(RegExp(r'\s+'));
          logger.info('  Processing coordinates element with ${lines.length} lines.');
          for (var line in lines) {
            final parts = line.trim().split(',');
            if (parts.length >= 2) {
              final longitude = double.tryParse(parts[0]);
              final latitude = double.tryParse(parts[1]);
              double altitude = 0;
              if (parts.length >= 3) {
                altitude = double.tryParse(parts[2]) ?? 0;
              }
              if (longitude != null && latitude != null) {
                routePoints.add(RoutePoint(latitude: latitude, longitude: longitude, altitude: altitude));
                if (routePoints.length % 100 == 0) {
                  logger.info('    Parsed point ${routePoints.length}: Lat: $latitude, Lon: $longitude, Alt: $altitude');
                }
              }
            } else {
              logger.warning('    Skipping coordinate line due to insufficient parts: $line');
            }
          }
        }
      } else {
        logger.warning('KML parsing failed: No <gx:Track> or <coordinates> found.');
      }
    }

    // Add arrival airport as the last point
    routePoints.add(RoutePoint(
      latitude: arrivalAirport.latitude,
      longitude: arrivalAirport.longitude,
      altitude: 0,
    ));

    logger.info('Parsed ${routePoints.length} total route points from KML.');

    // Update state variables if KML provided time data
    if (startTime != null && endTime != null) {
      logger.info('Updating flight date and duration from KML data.');
      setState(() {
        final nonNullStartTime = startTime as DateTime;
        final nonNullEndTime = endTime as DateTime;
        _selectedFlightDate = nonNullStartTime;
        _dateController.text = DateFormat('yyyy-MM-dd HH:mm').format(nonNullStartTime);
        final calculatedDuration = nonNullEndTime.difference(nonNullStartTime);
        _flightDuration = calculatedDuration;
        _durationController.text = '${calculatedDuration.inHours.toString().padLeft(2, '0')}:${calculatedDuration.inMinutes.remainder(60).toString().padLeft(2, '0')}';
      });
    }

    return routePoints;
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

      // Ensure _selectedFlightDate is not null before using it
      if (_selectedFlightDate == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a flight date.')),
          );
        }
        setState(() => _isSaving = false);
        return;
      }

      // Recalculate _flightDuration if KML was not used or if it's still null/zero
      if (_kmlFileResult == null || _flightDuration == null || _flightDuration == Duration.zero) {
        final durationParts = _durationController.text.split(':').map(int.parse).toList();
        _flightDuration = Duration(hours: durationParts[0], minutes: durationParts[1]);
      }

      // Ensure _flightDuration is not null before using it
      if (_flightDuration == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter a flight duration.')),
          );
        }
        setState(() => _isSaving = false);
        return;
      }

      List<RoutePoint> routePathForDb;
      List<RoutePoint> directRoutePathForDb;

      // Calculate the direct route path first
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
      directRoutePathForDb = routePositions
          .where((p) => p.length >= 2 && p[0] != null && p[1] != null)
          .map((p) => RoutePoint(latitude: p[1]!.toDouble(), longitude: p[0]!.toDouble()))
          .toList();

      logger.info('Inside _saveFlight: _kmlFileResult is null: ${_kmlFileResult == null}');
      if (_kmlFileResult != null) {
        logger.info('Inside _saveFlight: _kmlFileResult.files.single.bytes is null: ${_kmlFileResult!.files.single.bytes == null}');
      }

      if (_kmlFileResult != null && _kmlFileResult!.files.single.bytes != null) {
        logger.info('KML file found, parsing...');
        final kmlContent = String.fromCharCodes(_kmlFileResult!.files.single.bytes!);
        routePathForDb = _parseKml(kmlContent, departure, arrival);
        // If KML parsing fails or returns an empty path, fallback to the direct route
        if (routePathForDb.length <= 2) {
          logger.warning('KML parsing resulted in an empty or invalid path. Falling back to direct route.');
          routePathForDb = directRoutePathForDb;
        }
      } else {
        logger.info('No KML file, generating direct route.');
        routePathForDb = directRoutePathForDb;
      }

      logger.info('Saving flight with ${routePathForDb.length} points in routePath and ${directRoutePathForDb.length} points in directRoutePath.');

      logger.info('Saving flight with ${routePathForDb.length} points in routePath and ${directRoutePathForDb.length} points in directRoutePath.');

      final FlightsCompanion flightCompanion = FlightsCompanion(
        id: _flightToEdit != null ? Value(_flightToEdit!.flight.id) : const Value.absent(),
        departureAirportId: Value(departure.id),
        arrivalAirportId: Value(arrival.id),
        flightDate: Value(_selectedFlightDate!),
        flightDuration: Value(_flightDuration!),
        distance: Value(distanceInMeters),
        routePath: Value(routePathForDb),
        directRoutePath: Value(directRoutePathForDb),
        flightNumber: Value(_flightNumberController.text),
        airplaneType: Value(_airplaneTypeController.text),
        registration: Value(_registrationController.text),
        seat: Value(_seatController.text),
        seatType: Value(_selectedSeatType),
        flightClass: Value(_selectedFlightClass),
        flightReason: Value(_selectedFlightReason),
        remoteID: _flightToEdit != null ? Value(_flightToEdit!.flight.remoteID) : const Value.absent(),
        editedAt: Value(DateTime.now()),
        syncedAt: _flightToEdit != null ? Value(_flightToEdit!.flight.syncedAt) : const Value.absent(),
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
      context: mounted ? context : throw Exception('Context not available'),
      delegate: AirportSearchDelegate(airports),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Flight Manually')),
      drawer: const AppDrawer(), // Use const as AppDrawer is a StatelessWidget
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
                      items: SeatType.values.map<DropdownMenuItem<SeatType>>((SeatType type) {
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
              const SizedBox(height: 16),
              DropdownButtonFormField<FlightClass>(
                value: _selectedFlightClass,
                decoration: const InputDecoration(
                  labelText: 'Flight Class',
                  border: OutlineInputBorder(),
                ),
                items: FlightClass.values.map<DropdownMenuItem<FlightClass>>((FlightClass type) {
                  return DropdownMenuItem<FlightClass>(
                    value: type,
                    child: Text(type.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (FlightClass? newValue) {
                  setState(() {
                    _selectedFlightClass = newValue;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<FlightReason>(
                value: _selectedFlightReason,
                decoration: const InputDecoration(
                  labelText: 'Flight Reason',
                  border: OutlineInputBorder(),
                ),
                items: FlightReason.values.map<DropdownMenuItem<FlightReason>>((FlightReason type) {
                  return DropdownMenuItem<FlightReason>(
                    value: type,
                    child: Text(type.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (FlightReason? newValue) {
                  setState(() {
                    _selectedFlightReason = newValue;
                  });
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _pickKmlFile,
                icon: const Icon(Icons.upload_file),
                label: Text(_kmlFileResult == null ? 'Pick KML File' : 'KML File Selected: ${_kmlFileResult!.files.single.name}'),
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
