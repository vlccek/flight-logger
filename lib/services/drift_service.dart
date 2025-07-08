// lib/services/drift_service.dart

import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flight_logger/services/route_calculation_service.dart';
import 'package:flight_logger/utils/logger.dart';
import 'package:geodesy/geodesy.dart';
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';
import '../database/database.dart';

class FlightWithDetails {
  final Flight flight;
  final Airport departureAirport;
  final Airport arrivalAirport;

  FlightWithDetails({
    required this.flight,
    required this.departureAirport,
    required this.arrivalAirport,
  });
}

class DriftService {
  // 1. Private constructor - prevents creating instances with new DriftService()
  DriftService._();

  // 2. The single, static, final instance of the service.
  // It's created once and can be accessed from anywhere.
  static final DriftService instance = DriftService._();

  // 3. The database instance is created once with the service.
  final AppDatabase _db = AppDatabase();

  Future<int> countFlights() async {
    final countExpression = _db.flights.id.count();
    final query = _db.selectOnly(_db.flights)..addColumns([countExpression]);
    final result = await query
        .map((row) => row.read(countExpression))
        .getSingle();
    return result ?? 0;
  }

  /// Seeds the database with a few sample flights for testing purposes.
  /// in the 'airports' table.
  Future<void> seedFlightsWithTestData() async {
    logDebug('Seeding database with sample flights and calculating routes...');

    // 1. Instantiate the services we'll need.
    final routeCalculator = RouteCalculationService();
    final geodesy = Geodesy();

    // 2. Fetch the airports we need from the database to get their IDs and coordinates.
    final prague = await (_db.select(
      _db.airports,
    )..where((a) => a.icaoCode.equals('LKPR'))).getSingleOrNull();
    final london = await (_db.select(
      _db.airports,
    )..where((a) => a.icaoCode.equals('EGLL'))).getSingleOrNull();
    final sydney = await (_db.select(
      _db.airports,
    )..where((a) => a.icaoCode.equals('YSSY'))).getSingleOrNull();

    if (prague == null || london == null || sydney == null) {
      logDebug(
        'Could not seed flights: Required airports (LKPR, EGLL, LIRF) not found.',
      );
      return;
    }

    // 3. Create a helper function to avoid repeating the calculation logic.
    // This makes the code cleaner and easier to read.
    List<RoutePoint> _calculatePath(Airport departure, Airport arrival) {
      final startLatLng = LatLng(departure.latitude, departure.longitude);
      final endLatLng = LatLng(arrival.latitude, arrival.longitude);
      final distance = geodesy
          .distanceBetweenTwoGeoPoints(startLatLng, endLatLng)
          .toInt();
      final pointCount = routeCalculator.calculatePointsForRoute(distance);
      final positions = routeCalculator.generateRoutePositions(
        startLatLng,
        endLatLng,
        pointCount,
      );

      return positions
          .where((p) => p[0] != null && p[1] != null)
          .map(
            (p) => RoutePoint(
              latitude: p[1]!.toDouble(),
              longitude: p[0]!.toDouble(),
            ),
          )
          .toList();
    }

    // 4. Prepare a list of flights, now including the calculated routePath.
    final List<FlightsCompanion> flightsToSeed = [
      // Flight 1: Prague to London
      FlightsCompanion.insert(
        departureAirportId: prague.id,
        arrivalAirportId: london.id,
        flightDate: DateTime(2024, 5, 20, 10, 30),
        flightDuration: const Duration(hours: 2, minutes: 5),
        distance: geodesy
            .distanceBetweenTwoGeoPoints(
              LatLng(prague.latitude, prague.longitude),
              LatLng(london.latitude, london.longitude),
            )
            .toInt(),
        routePath: _calculatePath(
          prague,
          london,
        ), // Calculate and assign the path
      ),
      // Flight 2: London to Rome
      FlightsCompanion.insert(
        departureAirportId: london.id,
        arrivalAirportId: sydney.id,
        flightDate: DateTime(2024, 5, 22, 14, 0),
        flightDuration: const Duration(hours: 2, minutes: 40),
        distance: geodesy
            .distanceBetweenTwoGeoPoints(
              LatLng(london.latitude, london.longitude),
              LatLng(sydney.latitude, sydney.longitude),
            )
            .toInt(),
        routePath: _calculatePath(
          london,
          sydney,
        ), // Calculate and assign the path
      ),
      // Flight 3: Rome back to Prague
      FlightsCompanion.insert(
        departureAirportId: sydney.id,
        arrivalAirportId: prague.id,
        flightDate: DateTime(2024, 5, 25, 18, 15),
        flightDuration: const Duration(hours: 1, minutes: 55),
        distance: geodesy
            .distanceBetweenTwoGeoPoints(
              LatLng(sydney.latitude, sydney.longitude),
              LatLng(prague.latitude, prague.longitude),
            )
            .toInt(),
        routePath: _calculatePath(
          sydney,
          prague,
        ), // Calculate and assign the path
      ),
    ];

    // 5. Use a batch operation to insert all flights at once.
    await _db.batch((batch) {
      batch.insertAll(_db.flights, flightsToSeed);
    });

    logDebug(
      'Seeding complete. ${flightsToSeed.length} sample flights with routes inserted.',
    );
  }

  // --- PRIVATE HELPER FOR DOWNLOADING ---

  /// Fetches JSON data from a given URL.
  /// Returns the JSON as a string.
  /// Throws an exception if the network request fails.
  Future<String> _fetchJsonFromUrl(String url) async {
    final uri = Uri.parse(url);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      // Successfully fetched the data.
      return response.body;
    } else {
      // If the server did not return a 200 OK response,
      // throw an exception.
      throw Exception(
        'Failed to load airport data from $url. Status code: ${response.statusCode}',
      );
    }
  }

  // --- PUBLIC IMPORT FUNCTION ---

  /// Downloads airport data from a specified URL and imports it into the database.
  /// This is the main public method to call from your UI.
  Future<void> importAirportsFromUrl(String url) async {
    try {
      logDebug('Starting airport data download from $url...');
      // 1. Download the JSON data from the web.
      final jsonString = await _fetchJsonFromUrl(url);

      logDebug('Download complete. Starting database import...');
      // 2. Call the existing import function with the downloaded data.
      await _importAirportsFromJsonString(jsonString);

      logDebug('Airport import finished successfully.');
    } catch (e) {
      // Catch any errors during download or parsing.
      logDebug('An error occurred during airport import: $e');
      // You might want to re-throw the exception or handle it in the UI.
      rethrow;
    }
  }

  /// Imports a list of airports from a JSON string into the database.
  /// Renamed to be a private helper method.
  Future<void> _importAirportsFromJsonString(String jsonString) async {
    final Map<String, dynamic> parsedJson = json.decode(jsonString);
    final List<AirportsCompanion> airportCompanions = [];

    for (final airportData in parsedJson.values) {
      if (airportData is Map<String, dynamic>) {
        // --- HERE IS THE FIX ---
        // Instead of casting directly to double, we first cast to num
        // and then convert to double. This works for both ints and doubles.
        final lat = (airportData['lat'] as num).toDouble();
        final lon = (airportData['lon'] as num).toDouble();
        // -----------------------

        airportCompanions.add(
          AirportsCompanion.insert(
            name: airportData['name'] as String,
            city: airportData['city'] as String,
            country: airportData['country'] as String,
            latitude: lat,
            // Use the converted value
            longitude: lon,
            // Use the converted value
            icaoCode: airportData['icao'] as String,
          ),
        );
      }
    }

    await _db.batch((batch) {
      batch.insertAll(
        _db.airports,
        airportCompanions,
        mode: InsertMode.insertOrReplace,
      );
    });

    logDebug('Processed ${airportCompanions.length} airports into the database.');
  }

  

  /// Parses a CSV string from Flightradar24 and imports the flights.
  /// Returns the number of flights that were successfully imported.
  Future<int> importFlightsFromCsv(String csvData) async {
    final routeCalculator = RouteCalculationService();
    final geodesy = Geodesy();

    final converter = CsvToListConverter(eol: '\n', shouldParseNumbers: false);
    final List<List<dynamic>> rows = converter.convert(csvData);

    if (rows.length < 2) return 0;

    final allAirports = await _db.select(_db.airports).get();
    final airportMap = {
      for (var airport in allAirports) airport.icaoCode.toUpperCase(): airport,
    };

    final List<FlightsCompanion> flightsToInsert = [];
    int successfullyParsedRows = 0;
    final icaoRegex = RegExp(r'\(.*?([A-Z]{4})\)');

    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];
      try {
        final fromStr = row[2] as String;
        final toStr = row[3] as String;

        final depIcaoMatch = icaoRegex.firstMatch(fromStr);
        final arrIcaoMatch = icaoRegex.firstMatch(toStr);

        if (depIcaoMatch == null || arrIcaoMatch == null) continue;

        final depIcao = depIcaoMatch.group(1)!.trim().toUpperCase();
        final arrIcao = arrIcaoMatch.group(1)!.trim().toUpperCase();

        final depAirport = airportMap[depIcao];
        final arrAirport = airportMap[arrIcao];

        if (depAirport == null || arrAirport == null) continue;

        final startLatLng = LatLng(depAirport.latitude, depAirport.longitude);
        final endLatLng = LatLng(arrAirport.latitude, arrAirport.longitude);

        final distanceInMeters = geodesy
            .distanceBetweenTwoGeoPoints(startLatLng, endLatLng)
            .toInt();
        final pointCount = routeCalculator.calculatePointsForRoute(
          distanceInMeters,
        );
        final routePositions = routeCalculator.generateRoutePositions(
          startLatLng,
          endLatLng,
          pointCount,
        );

        // THE ONLY CHANGE IS HERE:
        final routePathForDb = routePositions
            .map(
              (p) => RoutePoint(
                latitude: p[1]!.toDouble(),
                // Use ! to assert non-null and then convert
                longitude: p[0]!.toDouble(),
              ),
            )
            .toList();

        final dateStr = row[0] as String;
        final depTimeStr = row[4] as String;
        final durationStr = row[6] as String;
        final flightDateTime = DateTime.parse('$dateStr $depTimeStr');
        final durationParts = durationStr.split(':').map(int.parse).toList();
        final flightDuration = Duration(
          hours: durationParts[0],
          minutes: durationParts[1],
          seconds: durationParts[2],
        );

        flightsToInsert.add(
          FlightsCompanion.insert(
            departureAirportId: depAirport.id,
            arrivalAirportId: arrAirport.id,
            flightDate: flightDateTime,
            flightDuration: flightDuration,
            distance: distanceInMeters,
            routePath: routePathForDb,
          ),
        );
        successfullyParsedRows++;
      } catch (e) {
        logDebug('Failed to parse row $i: $e. Row data: $row');
      }
    }

    if (flightsToInsert.isNotEmpty) {
      await _db.batch((batch) {
        batch.insertAll(_db.flights, flightsToInsert);
      });
    }

    return successfullyParsedRows;
  }

  Stream<List<FlightWithDetails>> watchAllFlightsWithDetails() {
    // We define aliases for the airports table to join it twice.
    final departure = _db.alias(_db.airports, 'd');
    final arrival = _db.alias(_db.airports, 'a');

    final query = _db.select(_db.flights).join([
      innerJoin(
        departure,
        departure.id.equalsExp(_db.flights.departureAirportId),
      ),
      innerJoin(arrival, arrival.id.equalsExp(_db.flights.arrivalAirportId)),
    ]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return FlightWithDetails(
          flight: row.readTable(_db.flights),
          departureAirport: row.readTable(departure),
          arrivalAirport: row.readTable(arrival),
        );
      }).toList();
    });
  }

  Future<int> countAirports() async {
    // Create a count expression on the primary key column.
    final countExpression = _db.airports.id.count();

    // Build a query that selects only the calculated count.
    final query = _db.selectOnly(_db.airports)..addColumns([countExpression]);

    // Execute the query and read the single resulting value.
    final result = await query
        .map((row) => row.read(countExpression))
        .getSingle();

    // The result will be non-null, but we provide a fallback for safety.
    return result ?? 0;
  }

  void deleteFlight(int id) {
    // Create a delete query for the flights table.
    final query = _db.delete(_db.flights)..where((f) => f.id.equals(id));

    // Execute the delete operation.
    query.go();
  }

  Future<void> saveFlight(FlightsCompanion flight) async {
    _db.into(_db.flights).insert(flight, mode: InsertMode.insertOrReplace);
  }

  Future<List<Airport>> getAllAirports() async {
    // Fetch all airports from the database.
    return await _db.select(_db.airports).get();
  }

  /// Finds a single airport in the database by its ICAO code.
  /// Returns null if the airport is not found.
  Future<Airport?> findAirportByIcao(String icaoCode) async {
    return await (_db.select(_db.airports)
          ..where((a) => a.icaoCode.equals(icaoCode.toUpperCase())))
        .getSingleOrNull();
  }

  /// Finds a single airport in the database by its 3-letter IATA code.
  /// Note: This assumes you have IATA codes in your database. If not, you'll
  /// need to adjust your Airport table or use a different lookup method.
  Future<Airport?> findAirportByIata(String iataCode) async {
    // This is a placeholder. You need a way to link IATA to your airports.
    // If your airports table has an `iataCode` column, this would be:
    // return await (_db.select(_db.airports)..where((a) => a.iataCode.equals(iataCode))).getSingleOrNull();

    // For now, let's fake it by looking at the first 3 letters of the ICAO code.
    // THIS IS NOT RELIABLE FOR PRODUCTION.
    return await (_db.select(_db.airports)
          ..where((a) => a.icaoCode.like('$iataCode%')))
        .get()
        .then((results) => results.isNotEmpty ? results.first : null);
  }

  /// Calculates the distance between two airports using their stored coordinates.
  Future<int> calculateDistanceBetweenAirports(
    int departureId,
    int arrivalId,
  ) async {
    final dep = await (_db.select(
      _db.airports,
    )..where((a) => a.id.equals(departureId))).getSingle();
    final arr = await (_db.select(
      _db.airports,
    )..where((a) => a.id.equals(arrivalId))).getSingle();
    return Geodesy()
        .distanceBetweenTwoGeoPoints(
          LatLng(dep.latitude, dep.longitude),
          LatLng(arr.latitude, arr.longitude),
        )
        .toInt();
  }
}
