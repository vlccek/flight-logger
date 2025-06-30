// lib/services/route_calculation_service.dart

import 'package:geodesy/geodesy.dart';
import 'package:maplibre/maplibre.dart'; // Assuming you use LatLng from here or a similar class

/// A dedicated service for handling geographical calculations.
/// This keeps the business logic separate from database access and UI.
class RouteCalculationService {
  final Geodesy _geodesy = Geodesy();

  /// Generates a list of positions (route path) between a start and end point.
  List<Position> generateRoutePositions(
    LatLng start,
    LatLng end,
    int numberOfPoints,
  ) {
    final List<Position> route = [];

    route.add(Position(start.longitude, start.latitude));

    final num totalDistance = _geodesy.distanceBetweenTwoGeoPoints(start, end);
    final num bearing = _geodesy.bearingBetweenTwoGeoPoints(start, end);
    final double stepDistance = totalDistance / (numberOfPoints + 1);

    for (int i = 1; i <= numberOfPoints; i++) {
      final double currentDistance = stepDistance * i;
      final LatLng intermediatePoint = _geodesy
          .destinationPointByDistanceAndBearing(
            start,
            currentDistance,
            bearing,
          );
      route.add(
        Position(intermediatePoint.longitude, intermediatePoint.latitude),
      );
    }

    route.add(Position(end.longitude, end.latitude));
    return route;
  }

  /// Calculates an appropriate number of points for a route based on its distance.
  int calculatePointsForRoute(int distanceInMeters) {
    if (distanceInMeters < 50000) return 50; // < 50km
    if (distanceInMeters < 200000) return 100; // < 200km
    if (distanceInMeters < 1000000) return 200; // < 1000km
    return 500; // long routes
  }
}
