import 'package:geodesy/geodesy.dart';
import 'package:maplibre/maplibre.dart';

import '../models/routes.dart';

class RouteService {
  final Geodesy geodesy = Geodesy();

  Future<List<VisuRouteModel>> loadUserRoutes() async {
    return fakeloadUserRoutes();
  }

  // Simulates loading user routes from an API or database.

  Future<List<VisuRouteModel>> fakeloadUserRoutes() async {
    // Simulate a network call.
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      VisuRouteModel(
        id: '1',
        start: const LatLng(50.0755, 14.4378),
        // Prague
        end: const LatLng(49.1951, 16.6068),
        // Brno
        date: DateTime.now().subtract(const Duration(days: 7)),
        distance: 195000, // 195 km
      ),
      VisuRouteModel(
        distance: 170000,
        // 170 km
        id: '2',
        start: const LatLng(49.1951, 16.6068),
        // Brno
        end: const LatLng(49.8209, 18.2625),
        // Ostrava
        date: DateTime.now().subtract(const Duration(days: 3)),
      ),
      VisuRouteModel(
        id: '3',
        start: const LatLng(50.08804, 14.42076),
        // Prague
        end: const LatLng(40.71278, -74.00594),
        // New York
        date: DateTime.now().subtract(const Duration(days: 1)),
        distance: 6500000, // 6500 km
      ),
      VisuRouteModel(
        id: '4',
        start: const LatLng(50.0755, 14.4378),
        // Prague
        end: const LatLng(50.0755, 14.5378),
        // Prague + something
        date: DateTime.now(),
        distance: 10000, // 10 km
      ),
    ];
  }

  // Generates positions along a route.
  List<Position> generateRoutePositions(
    LatLng start,
    LatLng end,
    int numberOfPoints,
  ) {
    List<Position> route = [];
    route.add(Position(start.longitude, start.latitude));

    num totalDistance = geodesy.distanceBetweenTwoGeoPoints(start, end);
    num bearing = geodesy.bearingBetweenTwoGeoPoints(start, end);
    double stepDistance = totalDistance / (numberOfPoints + 1);

    for (int i = 1; i <= numberOfPoints; i++) {
      double currentDistance = stepDistance * i;
      LatLng intermediatePoint = geodesy.destinationPointByDistanceAndBearing(
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

  // Calculates the number of points for a route based on its distance.
  int calculatePointsForRoute(VisuRouteModel route) {
    if (route.distance == null) return 100;

    if (route.distance! < 50000) return 50; // < 50km
    if (route.distance! < 200000) return 100; // < 200km
    if (route.distance! < 1000000) return 200; // < 1000km
    return 500; // long routes
  }
}
