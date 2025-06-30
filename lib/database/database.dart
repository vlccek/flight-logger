// lib/database/database.dart

import 'package:drift/drift.dart';
import 'connection/unsupported.dart'
    if (dart.library.html) 'connection/web.dart'
    if (dart.library.io) 'connection/native.dart';
import 'dart:convert'; // Import for json encoding/decoding

part 'database.g.dart';

// --- HELPER CLASSES AND CONVERTERS ARE NOW DEFINED IN THIS FILE ---

/// A simple Dart class (PODO) to represent a single point in a route.
/// This is NOT a database table.
class RoutePoint {
  final double latitude;
  final double longitude;

  RoutePoint({required this.latitude, required this.longitude});

  factory RoutePoint.fromJson(Map<String, dynamic> json) {
    return RoutePoint(
      latitude: json['lat'] as double,
      longitude: json['lon'] as double,
    );
  }

  Map<String, dynamic> toJson() => {'lat': latitude, 'lon': longitude};
}

/// A custom TypeConverter to store a List<RoutePoint> as a single JSON string.
class RoutePathConverter extends TypeConverter<List<RoutePoint>, String> {
  const RoutePathConverter();

  @override
  List<RoutePoint> fromSql(String fromDb) {
    if (fromDb.isEmpty) return [];
    final List<dynamic> jsonList = json.decode(fromDb);
    return jsonList
        .map(
          (jsonItem) => RoutePoint.fromJson(jsonItem as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  String toSql(List<RoutePoint> value) {
    return json.encode(value.map((point) => point.toJson()).toList());
  }
}

/// A custom TypeConverter to store Dart's Duration object as an integer (seconds).
class DurationConverter extends TypeConverter<Duration, int> {
  const DurationConverter();

  @override
  Duration fromSql(int fromDb) => Duration(seconds: fromDb);

  @override
  int toSql(Duration value) => value.inSeconds;
}

// --- TABLE DEFINITIONS ---

@DataClassName('Airport')
class Airports extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get icaoCode => text().withLength(min: 4, max: 4).unique()();

  TextColumn get name => text()();

  TextColumn get city => text()();

  TextColumn get country => text()();

  RealColumn get latitude => real()();

  RealColumn get longitude => real()();
}

@DataClassName('Flight')
class Flights extends Table {
  IntColumn get id => integer().autoIncrement()();

  @ReferenceName('departingFlights')
  IntColumn get departureAirportId => integer().references(Airports, #id)();

  @ReferenceName('arrivingFlights')
  IntColumn get arrivalAirportId => integer().references(Airports, #id)();

  DateTimeColumn get flightDate => dateTime()();

  IntColumn get flightDuration => integer().map(const DurationConverter())();

  IntColumn get distance => integer()();

  TextColumn get routePath => text().map(const RoutePathConverter())();
}

// --- DATABASE CLASS ---

@DriftDatabase(tables: [Airports, Flights])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(connect());

  @override
  int get schemaVersion => 1;
}
