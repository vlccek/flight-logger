// lib/database/database.dart

import 'package:drift/drift.dart';
import 'connection/unsupported.dart'
    if (dart.library.html) 'connection/web.dart'
    if (dart.library.io) 'connection/native.dart';
import 'dart:convert'; // Import for json encoding/decoding

part 'database.g.dart';

// --- HELPER CLASSES AND CONVERTERS ARE NOW DEFINED IN THIS FILE ---

/// A simple Dart class (PODO) to represent a single point in a route.
class RoutePoint {
  final double latitude;
  final double longitude;
  final double? altitude; // New field for altitude

  RoutePoint({required this.latitude, required this.longitude, this.altitude});

  factory RoutePoint.fromJson(Map<String, dynamic> json) {
    return RoutePoint(
      latitude: json['lat'] as double,
      longitude: json['lon'] as double,
      altitude: json['alt'] as double?, // Deserialize altitude
    );
  }

  Map<String, dynamic> toJson() => {
        'lat': latitude,
        'lon': longitude,
        'alt': altitude, // Serialize altitude
      };
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

enum SeatType { none, window, middle, aisle }

class SeatTypeConverter extends TypeConverter<SeatType, int> {
  const SeatTypeConverter();
  @override
  SeatType fromSql(int fromDb) {
    return SeatType.values[fromDb];
  }

  @override
  int toSql(SeatType value) {
    return value.index;
  }
}

enum FlightClass { none, economy, premiumEconomy, business, first }

class FlightClassConverter extends TypeConverter<FlightClass, int> {
  const FlightClassConverter();
  @override
  FlightClass fromSql(int fromDb) {
    return FlightClass.values[fromDb];
  }

  @override
  int toSql(FlightClass value) {
    return value.index;
  }
}

enum FlightReason { none, leisure, business, crew, repositioning, other }

class FlightReasonConverter extends TypeConverter<FlightReason, int> {
  const FlightReasonConverter();
  @override
  FlightReason fromSql(int fromDb) {
    return FlightReason.values[fromDb];
  }

  @override
  int toSql(FlightReason value) {
    return value.index;
  }
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
  TextColumn get directRoutePath => text().map(const RoutePathConverter())(); // New column for direct path

  TextColumn get flightNumber => text().nullable()();
  TextColumn get airplaneType => text().nullable()();
  TextColumn get registration => text().nullable()();
  TextColumn get seat => text().nullable()();
  IntColumn get seatType => integer().map(const SeatTypeConverter()).nullable()();
  IntColumn get flightClass => integer().map(const FlightClassConverter()).nullable()();
  IntColumn get flightReason => integer().map(const FlightReasonConverter()).nullable()();
  IntColumn get remoteID => integer().nullable()();
  DateTimeColumn get editedAt => dateTime().nullable()();
  DateTimeColumn get syncedAt => dateTime().nullable()();
}

// --- DATABASE CLASS ---

@DriftDatabase(tables: [Airports, Flights])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(connect());

  @override
  int get schemaVersion => 11; // Increment schema version

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 11) {
            // The enums have been updated to include a 'none' value.
            // No data migration is needed, as the new value will be used for new entries.
          }
          if (from < 9) {
            // Drop old text columns and add new integer columns for enums
            await m.dropColumn(flights, "flight_class");
            await m.dropColumn(flights, "flight_reason");
            await m.addColumn(flights, flights.flightClass);
            await m.addColumn(flights, flights.flightReason);
          }
          if (from < 8) {
            await m.addColumn(flights, flights.editedAt);
          }
          if (from < 6) {
            // These columns were added as TextColumn in schema 6, now they are IntColumn in schema 9
            // The drop/add in schema 9 handles the type change.
          }
          if (from < 5) {
            await m.addColumn(flights, flights.directRoutePath);
          }
          if (from < 4) {
            // No direct column addition for altitude, as it's part of RoutePoint serialization.
            // This migration step primarily acknowledges the change in RoutePoint structure.
          }
          if (from < 3) {
            await m.addColumn(flights, flights.flightNumber);
          }
          if (from < 2) {
            await m.addColumn(flights, flights.airplaneType);
            await m.addColumn(flights, flights.registration);
            await m.addColumn(flights, flights.seat);
            await m.addColumn(flights, flights.seatType);
          }
        },
      );
}