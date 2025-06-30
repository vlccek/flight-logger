// lib/database/converters.dart
import 'dart:convert';
import 'package:drift/drift.dart';

// --- Define the PODO here ---
// This class represents a single point in a route path.
// It's a simple Dart object, not a database table.
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

// --- The TypeConverter remains the same, but now uses the local class ---
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
