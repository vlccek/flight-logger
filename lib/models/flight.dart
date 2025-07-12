import 'package:flight_logger/models/route_point.dart';

class Flight {
  final String id;
  final String userId;
  final String flightNumber;
  final String departureAirportId;
  final String arrivalAirportId;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final double distance;
  final String aircraftType;
  final List<RoutePoint> routePath;
  final List<RoutePoint> directRoutePath;

  Flight({
    required this.id,
    required this.userId,
    required this.flightNumber,
    required this.departureAirportId,
    required this.arrivalAirportId,
    required this.departureTime,
    required this.arrivalTime,
    required this.distance,
    required this.aircraftType,
    required this.routePath,
    required this.directRoutePath,
  });

  factory Flight.fromJson(Map<String, dynamic> json) {
    return Flight(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      flightNumber: json['flight_number'],
      departureAirportId: json['departure_airport_id'].toString(),
      arrivalAirportId: json['arrival_airport_id'].toString(),
      departureTime: DateTime.parse(json['departure_time']),
      arrivalTime: DateTime.parse(json['arrival_time']),
      distance: json['distance'].toDouble(),
      aircraftType: json['aircraft_type'],
      routePath: (json['route_path'] as List)
          .map((e) => RoutePoint.fromJson(e))
          .toList(),
      directRoutePath: (json['direct_route_path'] as List)
          .map((e) => RoutePoint.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'flight_number': flightNumber,
      'departure_airport_id': departureAirportId,
      'arrival_airport_id': arrivalAirportId,
      'departure_time': departureTime.toIso8601String(),
      'arrival_time': arrivalTime.toIso8601String(),
      'distance': distance,
      'aircraft_type': aircraftType,
      'route_path': routePath.map((e) => e.toJson()).toList(),
      'direct_route_path': directRoutePath.map((e) => e.toJson()).toList(),
    };
  }
}
