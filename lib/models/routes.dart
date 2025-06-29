
// Data model for a single route.
import 'package:geodesy/geodesy.dart';

class VisuRouteModel {
  final String id;
  final LatLng start;
  final LatLng end;
  final DateTime date;
  final double? distance; // Distance in meters.

  VisuRouteModel({
    required this.id,
    required this.start,
    required this.end,
    required this.date,
    this.distance,
  });
}

// Service for