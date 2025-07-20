import 'dart:convert';
import 'package:flight_logger/models/route_point.dart';

class Flight {
  final String id;
  final String userId;
  final String flightNumber;
  final String? flightReason;
  final String departureAirportId;
  final String arrivalAirportId;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final double distance;
  final String aircraftType;
  final String? airplaneRegistration;
  final String? seat;
  final String? seatType;
  final String? flightClass;
  final DateTime? editedAt; // New field
  final List<RoutePoint> routePath;
  final List<RoutePoint> directRoutePath;

  Flight({
    required this.id,
    required this.userId,
    required this.flightNumber,
    this.flightReason,
    required this.departureAirportId,
    required this.arrivalAirportId,
    required this.departureTime,
    required this.arrivalTime,
    required this.distance,
    required this.aircraftType,
    this.airplaneRegistration,
    this.seat,
    this.seatType,
    this.flightClass,
    this.editedAt,
    required this.routePath,
    required this.directRoutePath,
  });

  factory Flight.fromJson(Map<String, dynamic> json) {
    return Flight(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      flightNumber: json['flight_number']?.toString() ?? '',
      flightReason: json['flight_reason']?.toString() ?? '',
      departureAirportId: json['departure_airport_id']?.toString() ?? '',
      arrivalAirportId: json['arrival_airport_id']?.toString() ?? '',
      departureTime: json['departure_time'] != null
          ? DateTime.parse(json['departure_time'])
          : DateTime.now(),
      arrivalTime: json['arrival_time'] != null
          ? DateTime.parse(json['arrival_time'])
          : DateTime.now(),
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
      aircraftType: json['aircraft_type']?.toString() ?? '',
      airplaneRegistration: json['airplane_registration']?.toString(),
      seat: json['seat']?.toString(),
      seatType: json['seat_type']?.toString(),
      flightClass: json['flight_class']?.toString(),
      // add one hour for correction TODO
      editedAt: DateTime.parse(json['edited_at']).add(const Duration(hours: 1)),
      routePath: _parseRoutePath(json['route_path']),
      directRoutePath: _parseRoutePath(json['direct_route_path']),
    );
  }

  static List<RoutePoint> _parseRoutePath(dynamic data) {
    if (data == null) {
      return [];
    }
    if (data is String) {
      try {
        data = jsonDecode(data);
      } catch (e) {
        // Handle error if string is not valid JSON
        return [];
      }
    }
    if (data is List) {
      return data
          .map((e) => RoutePoint.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'flight_number': flightNumber,
      'flight_reason': flightReason,
      'departure_airport_id': departureAirportId,
      'arrival_airport_id': arrivalAirportId,
      'departure_time': departureTime.toIso8601String(),
      'arrival_time': arrivalTime.toIso8601String(),
      'distance': distance,
      'aircraft_type': aircraftType,
      'airplane_registration': airplaneRegistration,
      'seat': seat,
      'seat_type': seatType,
      'flight_class': flightClass,
      'edited_at': editedAt?.toIso8601String(),
      'route_path': jsonEncode(routePath.map((e) => e.toJson()).toList()),
      'direct_route_path': jsonEncode(
        directRoutePath.map((e) => e.toJson()).toList(),
      ),
    };
  }
}
