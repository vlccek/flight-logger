// lib/services/drift_service.dart

import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flight_logger/services/route_calculation_service.dart';
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

  Future<void> diagnoseAirportLookup(String depIcao, String arrIcao) async {
    print('--- DIAGNOSING AIRPORT LOOKUP ---');
    print('Searching for Departure: "$depIcao" (Length: ${depIcao.length})');
    print('Searching for Arrival: "$arrIcao" (Length: ${arrIcao.length})');

    // 1. Direct database query (case-sensitive by default in Dart)
    final depFromDb = await (_db.select(
      _db.airports,
    )..where((a) => a.icaoCode.equals(depIcao))).getSingleOrNull();
    final arrFromDb = await (_db.select(
      _db.airports,
    )..where((a) => a.icaoCode.equals(arrIcao))).getSingleOrNull();

    print('Direct DB query for "$depIcao" found: ${depFromDb != null}');
    print('Direct DB query for "$arrIcao" found: ${arrFromDb != null}');

    // 2. Check the keys in the pre-fetched map
    final allAirports = await _db.select(_db.airports).get();
    final airportMap = {
      for (var airport in allAirports) airport.icaoCode: airport,
    };

    final depFromMap = airportMap[depIcao];
    final arrFromMap = airportMap[arrIcao];

    print('Lookup in map for "$depIcao" found: ${depFromMap != null}');
    print('Lookup in map for "$arrIcao" found: ${arrFromMap != null}');

    // 3. List a few keys from the map to see their format
    print('Sample keys from airport map: ${airportMap.keys.take(5).toList()}');

    // 4. Check if the key exists in a case-insensitive way
    final caseInsensitiveMatchDep = airportMap.keys.any(
      (key) => key.toUpperCase() == depIcao.toUpperCase(),
    );
    final caseInsensitiveMatchArr = airportMap.keys.any(
      (key) => key.toUpperCase() == arrIcao.toUpperCase(),
    );
    print('Case-insensitive match for "$depIcao": $caseInsensitiveMatchDep');
    print('Case-insensitive match for "$arrIcao": $caseInsensitiveMatchArr');

    print('--- END OF DIAGNOSIS ---');
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
      print('Starting airport data download from $url...');
      // 1. Download the JSON data from the web.
      final jsonString = await _fetchJsonFromUrl(url);

      print('Download complete. Starting database import...');
      // 2. Call the existing import function with the downloaded data.
      await _importAirportsFromJsonString(jsonString);

      print('Airport import finished successfully.');
    } catch (e) {
      // Catch any errors during download or parsing.
      print('An error occurred during airport import: $e');
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
        airportCompanions.add(
          AirportsCompanion.insert(
            name: airportData['name'] as String,
            city: airportData['city'] as String,
            country: airportData['country'] as String,
            latitude: airportData['lat'] as double,
            longitude: airportData['lon'] as double,
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

    print('Processed ${airportCompanions.length} airports into the database.');
  }

  /// Finds a single airport in the database by its ICAO code.
  /// Returns null if the airport is not found.
  Future<Airport?> _findAirportByIcao(String icaoCode) async {
    return await (_db.select(
      _db.airports,
    )..where((a) => a.icaoCode.equals(icaoCode))).getSingleOrNull();
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
        print('Failed to parse row $i: $e. Row data: $row');
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
    final result = await query.map((row) => row.read(countExpression)).getSingle();

    // The result will be non-null, but we provide a fallback for safety.
    return result ?? 0;
  }
}
